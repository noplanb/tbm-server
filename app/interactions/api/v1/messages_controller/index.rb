class Api::V1::MessagesController::Index < ActiveInteraction::Base
  object :user

  def execute
    Kvstore::GetMessages.new(user).call
  end
end
