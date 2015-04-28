require 'no_plan_b/utils/text_utils'

class Connection < ActiveRecord::Base
  include AASM

  belongs_to :creator, class_name: 'User'
  belongs_to :target, class_name: 'User'

  validates :creator_id, :target_id, :status, presence: true, on: :create

  before_create :check_for_dups

  after_create :set_ckey

  aasm column: :status do
    state :voided, initial: true
    state :established

    event :establish do
      transitions from: :voided, to: :established
    end

    event :void do
      transitions from: :established, to: :voided
    end
  end

  scope :for_user_id, ->(user_id) { where ['creator_id = ? OR target_id = ?', user_id, user_id] }
  scope :between_creator_and_target, ->(creator_id, target_id) { where ['creator_id = ? AND target_id = ?', creator_id, target_id] }

  def self.live
    established
  end

  def self.live_between(user1_id, user2_id)
    between_creator_and_target(user1_id, user2_id).live + between_creator_and_target(user2_id, user1_id).live
  end

  def self.between(user1_id, user2_id)
    between_creator_and_target(user1_id, user2_id) + between_creator_and_target(user2_id, user1_id)
  end

  def self.find_or_create(creator_id, target_id)
    between(creator_id, target_id).first || create(creator_id: creator_id, target_id: target_id, status: :established)
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
    return false unless established?
    Kvstore.where('key1 LIKE ?', "#{key_search(creator, target)}%").count > 0 &&
      Kvstore.where('key1 LIKE ?', "#{key_search(target, creator)}%").count > 0
  end

  private

  def key_search(sender, receiver)
    "#{sender.mkey}-#{receiver.mkey}"
  end
end
