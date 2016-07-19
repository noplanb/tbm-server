class Messages::Show < ActiveInteraction::Base
  object :user
  string :id

  def execute
    message_data(compose(Messages::Get::Message, inputs))
  end

  private

  def message_data(message)
    message = JSON.parse(message.value)
    message['type'] = 'video' unless message['type']
    message.except('videoId', 'messageId')
  end
end
