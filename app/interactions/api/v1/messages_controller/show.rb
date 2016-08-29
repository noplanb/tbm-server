class Api::V1::MessagesController::Show < Api::BaseInteraction
  object :user
  string :id

  def execute
    message = Message.by_message_id(id).by_sender_or_receiver(user.mkey).first
    message ? message_data(message) : {}
  end

  private

  def message_data(msg)
    { type: msg.message_type,
      transcription: msg.transcription }
  end
end
