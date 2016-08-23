class Api::V1::MessagesController::Create < Api::BaseInteraction
  object :user # message sender
  string :receiver_mkey
  string :type
  string :body, default: nil
  string :id, default: -> { DateTime.now.strftime('%Q') }

  def execute
    compose(namespace::Get::Type, type: type)
    receiver = compose(namespace::Get::User, mkey: receiver_mkey, relation: :receiver)
    connection = compose(namespace::Get::Connection, user_1: user, user_2: receiver)
    kvstore_record = create_record(receiver, connection)
    Notifications::Send::Received.run(
      sender: user, receiver: receiver, kvstore: kvstore_record)
  end

  private

  def create_record(receiver, connection)
    key1 = Kvstore.generate_id_key(user, receiver, connection)
    Kvstore.create_or_update(key1: key1, key2: id, value: build_value)
  end

  def build_value
    { 'type' => type,
      'messageId' => id,
      'body' => Emojimmy.emoji_to_token(body) }.select { |_, v| v }.to_json
  end
end
