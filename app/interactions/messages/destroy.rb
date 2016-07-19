class Messages::Destroy < ActiveInteraction::Base
  object :user
  string :id

  def execute
    message = compose(Messages::Get::Message, inputs)
    message.destroy
  end
end
