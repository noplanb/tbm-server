class Api::V1::MessagesController::Index < Api::BaseInteraction
  object :user

  def execute
    Kvstore::GetMessages.new(user).call
  end
end
