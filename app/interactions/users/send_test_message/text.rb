class Users::SendTestMessage::Text < Users::SendTestMessage
  string :body

  def execute
    compose(Api::V1::MessagesController::Create,
      user: sender, receiver_mkey: receiver.mkey, type: 'text', body: body)
  end
end
