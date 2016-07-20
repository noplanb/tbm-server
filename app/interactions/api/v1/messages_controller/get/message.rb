class Api::V1::MessagesController::Get::Message < ActiveInteraction::Base
  object :user
  string :id

  def execute
    message = Kvstore.where(key2: id).first
    validate_presence(message) && validate_ownership(message)
    message
  end

  private

  def validate_presence(message)
    return true if message
    errors.add(:message, "not found by key2=#{id}")
    false
  end

  def validate_ownership(message)
    return true if message.key1.include?(user.mkey)
    errors.add(:message, 'not associated with user')
    false
  end
end
