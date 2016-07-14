class Messages::Create < ActiveInteraction::Base
  ALLOWED_VALUE_TYPES = %w(video text)

  object :user
  string :id
  string :receiver_mkey
  hash :value do
    string :type
    string :body, default: nil
    string :transcription, default: nil
  end

  validate :value_type_must_be_allowed

  def execute
    receiver = compose(Messages::SetUser, mkey: receiver_mkey, relation: :receiver)
    connection = compose(Messages::SetConnection, user_1: user, user_2: receiver)
    create_record(receiver, connection)
  end

  private

  def create_record(receiver, connection)
    key1 = Kvstore.generate_id_key(user, receiver, connection)
    Kvstore.create(key1: key1, key2: id, value: striped_value.merge(message_id: id).to_json)
  end

  def striped_value
    value.select { |_, value| value }
  end

  #
  # validators
  #

  def value_type_must_be_allowed
    unless ALLOWED_VALUE_TYPES.include?(value[:type])
      errors.add(:type, "#{value[:type]} is not allowed")
    end
  end
end
