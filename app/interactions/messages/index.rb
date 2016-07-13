class Messages::Index < ActiveInteraction::Base
  object :user

  def execute
    Kvstore::GetMessages.new(user).call
  end
end
