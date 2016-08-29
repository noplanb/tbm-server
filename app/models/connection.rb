require 'no_plan_b/utils/text_utils'

class Connection < ActiveRecord::Base
  include AASM
  include EventNotifiable

  belongs_to :creator, class_name: 'User'
  belongs_to :target, class_name: 'User'

  validates :creator_id, :target_id, :status, presence: true, on: :create

  before_create :check_for_dups

  after_create :set_ckey

  aasm column: :status do
    state :voided, initial: true
    state :established
    state :hidden_by_creator
    state :hidden_by_target
    state :hidden_by_both

    event :establish, after: :notify_state_changed do
      transitions from: :voided, to: :established
    end

    event :void, after: :notify_state_changed do
      transitions from: :established, to: :voided
    end
  end

  scope :live, -> { where.not(status: :voided) }

  scope :for_user_id, -> (user_id) { where ['creator_id = ? OR target_id = ?', user_id, user_id] }
  scope :between_creator_and_target, -> (creator_id, target_id) { where ['creator_id = ? AND target_id = ?', creator_id, target_id] }

  def self.live_between(user1_id, user2_id)
    between_creator_and_target(user1_id, user2_id).where.not(status: :voided) + between_creator_and_target(user2_id, user1_id).where.not(status: :voided)
  end

  def self.between(user1_id, user2_id)
    between_creator_and_target(user1_id, user2_id) + between_creator_and_target(user2_id, user1_id)
  end

  def self.find_or_create(creator_id, target_id)
    connection = between(creator_id, target_id).first || create(creator_id: creator_id, target_id: target_id)
    connection.establish! if connection.may_establish?
    connection
  end

  def check_for_dups
    if Connection.live_between(creator_id, target_id).present?
      fail "Cannot create a connection between #{creator_id} and #{target_id} a live one already exists."
    end
  end

  def set_ckey
    self.ckey = "#{creator_id}_#{target_id}_#{NoPlanB::TextUtils.random_string(20)}" if ckey.blank?
    save
  end

  def active?
    return false if voided?
    Kvstore.where('key1 LIKE ?', "#{key_search(creator, target)}%").count > 0 &&
      Kvstore.where('key1 LIKE ?', "#{key_search(target, creator)}%").count > 0
  end

  def id_for_events
    ckey
  end

  private

  def key_search(sender, receiver)
    "#{sender.mkey}-#{receiver.mkey}"
  end
end
