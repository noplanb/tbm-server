class Messages::Show < ActiveInteraction::Base
  object :user
  string :id

  def execute
    message = compose(Messages::Get::Message, inputs)
    JSON.parse(message.value).except('videoId', 'messageId')
  end
end
