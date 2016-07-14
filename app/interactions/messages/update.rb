class Messages::Update < ActiveInteraction::Base
  object :user
  string :id
  string :sender
  string :status

  def execute

  end
end
