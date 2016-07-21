class Api::V1::MessagesController::Destroy < Api::BaseInteraction
  object :user
  string :id

  def execute
    message = compose(namespace::Get::Message, inputs)
    message.destroy
  end
end
