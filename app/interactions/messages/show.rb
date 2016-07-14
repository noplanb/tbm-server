class Messages::Show < ActiveInteraction::Base
  object :user
  string :id

  def execute
    {}
  end
end
