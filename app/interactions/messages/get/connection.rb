class Messages::Get::Connection < ActiveInteraction::Base
  object :user_1, class: User
  object :user_2, class: User

  def execute
    connection = ::Connection.between(user_1.id, user_2.id).first
    validate_connection_presence(connection)
    connection
  end

  private

  def validate_connection_presence(connection)
    errors.add(:connection, 'not found between users') unless connection
  end
end
