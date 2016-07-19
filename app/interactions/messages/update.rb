class Messages::Update < ActiveInteraction::Base
  ALLOWED_STATUSES = %w(uploaded downloaded viewed)

  object :user # message receiver
  string :id
  string :sender_mkey
  string :type
  string :status

  validates :status, inclusion: { in: ALLOWED_STATUSES,
                                  message: '%{value} is not allowed' }

  def execute
    compose(Messages::Get::Type, type: type)
    sender = compose(Messages::Get::User, mkey: sender_mkey, relation: :sender)
    connection = compose(Messages::Get::Connection, user_1: user, user_2: sender)
    update_record(sender, connection)
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
