require 'no_plan_b/utils/text_utils'

class User < ActiveRecord::Base
  DEVICE_PLATFORMS = [:ios, :android]

  include EnumHandler

  has_many :connections_as_creator, class_name: 'Connection', foreign_key: :creator_id, dependent: :destroy
  has_many :connections_as_target, class_name: 'Connection', foreign_key: :target_id, dependent: :destroy

  validates :mobile_number, uniqueness: true

  define_enum :device_platform, DEVICE_PLATFORMS
  define_enum :status, [:initialized, :verified], primary: true

  # GARF: Change this to before_create when we finalize the algorithm for creating keys. Right now I incorporate id
  # in the key so I need to have after_create
  after_create :set_status_initialized, :ensure_names_not_null, :set_keys

  def self.find_by_raw_mobile_number(value)
    find_by_mobile_number GlobalPhone.normalize(value)
  end

  def self.search(query)
    limit(10)
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

  def live_connection_count
    Connection.for_user_id(id).live.count
  end

  def connection_count
    Connection.for_user_id(id).count
  end

  def has_app?
    device_platform.blank? ? false : true
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
    r[:has_app] = has_app?.to_s
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
    update_attributes({ verification_code: random_number(Settings.verification_code_length),
                        verification_date_time: (Settings.verification_code_lifetime_minutes.minutes.from_now) })
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
  def set_status_initialized
    update_attribute(:status, :initialized)
  end

  def ensure_names_not_null
    self.first_name = '' if first_name.nil?
    self.last_name = '' if last_name.nil?
    save
  end

  def set_keys
    update_attributes(auth: gen_key('auth'), mkey: gen_key('mkey'))
  end

  def gen_key(type)
    k = Figaro.env.user_debuggable_keys? ? "#{first_name}_#{last_name}_#{id}_#{type}_" : ''
    k += NoPlanB::TextUtils.random_string(20)
    k.gsub(' ', '')
  end
end
