class Api::V1::MessagesController::Get::Message < Api::BaseInteraction
  object :user
  string :id

  def execute
    message = Kvstore.where(key2: id).find { |msg| msg.key1.include?(user.mkey) }
    validate_presence(message)
    message
  end

  private

  def validate_presence(message)
    return true if message
    errors.add(:message, "not found by key2=#{id} by user ownership")
    false
  end
end
