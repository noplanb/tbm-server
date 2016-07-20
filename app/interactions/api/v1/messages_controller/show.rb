class Api::V1::MessagesController::Show < ActiveInteraction::Base
  object :user
  string :id

  def execute
    message_data(compose(self.class.parent::Get::Message, inputs))
  end

  private

  def message_data(message)
    message = JSON.parse(message.value)
    message['type'] = 'video' unless message['type']
    message.except('videoId', 'messageId')
  end
end
