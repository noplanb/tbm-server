class Api::V1::MessagesController::Update < Api::BaseInteraction
  ALLOWED_STATUSES = %w(uploaded downloaded viewed)

  object :user # message receiver
  string :id
  string :sender_mkey
  string :type
  string :status

  validates :status, inclusion: { in: ALLOWED_STATUSES,
                                  message: '%{value} is not allowed' }

  def execute
    compose(namespace::Get::Type, type: type)
    sender = compose(namespace::Get::User, mkey: sender_mkey, relation: :sender)
    connection = compose(namespace::Get::Connection, user_1: user, user_2: sender)
    kvstore = update_record(sender, connection)
    Notifications::Send::StatusUpdated.run(sender: sender, receiver: user, kvstore: kvstore)
  end

  private

  def update_record(sender, connection)
    key1 = Kvstore.generate_status_key(sender, user, connection)
    Kvstore.create_or_update(key1: key1, value: build_value)
  end

  def build_value
    { 'type' => type, 'messageId' => id, 'status' => status }.to_json
  end
end
