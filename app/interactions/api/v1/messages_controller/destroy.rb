class Api::V1::MessagesController::Destroy < ActiveInteraction::Base
  object :user
  string :id

  def execute
    message = compose(self.class.parent::Get::Message, inputs)
    message.destroy
  end
end
