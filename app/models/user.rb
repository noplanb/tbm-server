require 'no_plan_b/utils/text_utils'

class User < ActiveRecord::Base
  DEVICE_PLATFORMS = [:ios, :android]
  EMOJI_REGEXP = /[\u{203C}\u{2049}\u{20E3}\u{2122}\u{2139}\u{2194}-\u{2199}\u{21A9}-\u{21AA}\u{231A}-\u{231B}\u{23E9}-\u{23EC}\u{23F0}\u{23F3}\u{24C2}\u{25AA}-\u{25AB}\u{25B6}\u{25C0}\u{25FB}-\u{25FE}\u{2600}-\u{2601}\u{260E}\u{2611}\u{2614}-\u{2615}\u{261D}\u{263A}\u{2648}-\u{2653}\u{2660}\u{2663}\u{2665}-\u{2666}\u{2668}\u{267B}\u{267F}\u{2693}\u{26A0}-\u{26A1}\u{26AA}-\u{26AB}\u{26BD}-\u{26BE}\u{26C4}-\u{26C5}\u{26CE}\u{26D4}\u{26EA}\u{26F2}-\u{26F3}\u{26F5}\u{26FA}\u{26FD}\u{2702}\u{2705}\u{2708}-\u{270C}\u{270F}\u{2712}\u{2714}\u{2716}\u{2728}\u{2733}-\u{2734}\u{2744}\u{2747}\u{274C}\u{274E}\u{2753}-\u{2755}\u{2757}\u{2764}\u{2795}-\u{2797}\u{27A1}\u{27B0}\u{2934}-\u{2935}\u{2B05}-\u{2B07}\u{2B1B}-\u{2B1C}\u{2B50}\u{2B55}\u{3030}\u{303D}\u{3297}\u{3299}\u{1F004}\u{1F0CF}\u{1F170}-\u{1F171}\u{1F17E}-\u{1F17F}\u{1F18E}\u{1F191}-\u{1F19A}\u{1F1E7}-\u{1F1EC}\u{1F1EE}-\u{1F1F0}\u{1F1F3}\u{1F1F5}\u{1F1F7}-\u{1F1FA}\u{1F201}-\u{1F202}\u{1F21A}\u{1F22F}\u{1F232}-\u{1F23A}\u{1F250}-\u{1F251}\u{1F300}-\u{1F320}\u{1F330}-\u{1F335}\u{1F337}-\u{1F37C}\u{1F380}-\u{1F393}\u{1F3A0}-\u{1F3C4}\u{1F3C6}-\u{1F3CA}\u{1F3E0}-\u{1F3F0}\u{1F400}-\u{1F43E}\u{1F440}\u{1F442}-\u{1F4F7}\u{1F4F9}-\u{1F4FC}\u{1F500}-\u{1F507}\u{1F509}-\u{1F53D}\u{1F550}-\u{1F567}\u{1F5FB}-\u{1F640}\u{1F645}-\u{1F64F}\u{1F680}-\u{1F68A}]/

  include EnumHandler
  include AASM

  has_many :connections_as_creator, class_name: 'Connection', foreign_key: :creator_id, dependent: :destroy
  has_many :connections_as_target, class_name: 'Connection', foreign_key: :target_id, dependent: :destroy

  validates :mobile_number, uniqueness: true

  define_enum :device_platform, DEVICE_PLATFORMS

  aasm column: :status do
    state :initialized, initial: true
    state :registred
    state :invited
    state :verified

    event :register do
      transitions from: :initialized, to: :registred
    end

    event :invite do
      transitions from: :initialized, to: :invited
    end

    event :verify do
      transitions from: [:registered, :invited], to: :verified
    end
  end

  # GARF: Change this to before_create when we finalize the algorithm for creating keys. Right now I incorporate id
  # in the key so I need to have after_create
  before_save :set_keys, :strip_emoji

  def self.find_by_raw_mobile_number(value)
    find_by_mobile_number GlobalPhone.normalize(value)
  end

  def self.search(query)
    query_param = "%#{query}%"
    where('first_name LIKE ? OR last_name LIKE ? OR mobile_number LIKE ?', query_param, query_param, query_param)
  end

  def name
    [first_name, last_name].join(' ')
  end

  def info
    "#{name}[#{id}]"
  end

  def mobile_number=(value)
    super GlobalPhone.normalize(value)
  end

  def connected_user_ids
    live_connections = Connection.for_user_id(id).live
    live_connections.map { |c| c.creator_id == id ? c.target_id : c.creator_id }
  end

  def connected_users
    User.where ['id IN ?', connected_user_ids]
  end

  def connections
    Connection.for_user_id(id)
  end

  def live_connection_count
    connections.live.count
  end

  def connection_count
    connections.count
  end

  def active_connections
    connections.select(&:active?)
  end

  def app?
    device_platform.present?
  end

  # ==================
  # = App Attributes =
  # ==================

  def only_app_attrs_for_user
    r = attributes.symbolize_keys.slice(:id, :auth, :mkey, :first_name, :last_name, :mobile_number, :device_platform)
    r[:id] = r[:id].to_s
    r
  end

  def only_app_attrs_for_friend
    r = attributes.symbolize_keys.slice(:id, :mkey, :first_name, :last_name, :mobile_number, :device_platform)
    r[:id] = r[:id].to_s
    r[:has_app] = app?.to_s
    r
  end

  def only_app_attrs_for_friend_with_ckey(connected_user)
    conn = Connection.live_between(id, connected_user.id).first
    fail 'No connection found with connected user. This should never happen.' if conn.nil?
    only_app_attrs_for_friend.merge(ckey: conn.ckey, cid: conn.id)
  end

  # =====================
  # = Verification code =
  # =====================
  def reset_verification_code
    set_verification_code if verification_code.blank? || verification_code_will_expire_in?(2)
  end

  def get_verification_code
    reset_verification_code
    verification_code
  end

  def passes_verification(code)
    !verification_code_expired? && verification_code == code.gsub(/\s/, '')
  end

  def set_verification_code
    update_attributes(verification_code: random_number(Settings.verification_code_length),
                      verification_date_time: (Settings.verification_code_lifetime_minutes.minutes.from_now))
  end

  def random_number(n)
    rand.to_s[2..n + 1]
  end

  def verification_code_expired?
    verification_code_will_expire_in?(0)
  end

  def verification_code_will_expire_in?(n)
    return true if verification_code.blank? || verification_date_time.blank?
    return true if verification_date_time < n.minutes.from_now
    false
  end

  private

  # ==================
  # = Filter Actions =
  # ==================

  def set_keys
    self.auth = gen_key('auth') if auth.blank?
    self.mkey = gen_key('mkey') if mkey.blank?
  end

  def gen_key(type)
    k = Figaro.env.user_debuggable_keys? ? "#{first_name}_#{last_name}_#{id}_#{type}_" : ''
    k += NoPlanB::TextUtils.random_string(20)
    k.gsub(' ', '')
  end

  def strip_emoji
    self.first_name = first_name.to_s.gsub(EMOJI_REGEXP, '').strip
    self.last_name = last_name.to_s.gsub(EMOJI_REGEXP, '').strip
  end
end
