class Api::V1::MessagesController::Get::Connection < Api::BaseInteraction
  object :user_1, class: ::User
  object :user_2, class: ::User

  def execute
    connection = ::Connection.between(user_1.id, user_2.id).first
    validate_presence(connection)
    connection
  end

  private

  def validate_presence(connection)
    return true if connection
    errors.add(:connection, 'is not found between users')
    false
  end
end
