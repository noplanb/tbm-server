class Message < ActiveRecord::Base
  validates :sender, :receiver, :message_id, :message_type, presence: true

  scope :by_message_id, -> (message_id) { where(message_id: message_id) }
  scope :by_sender_or_receiver, -> (mkey) { where('sender = ? OR receiver = ?', mkey, mkey) }

  def self.create_or_update(to_find, to_update)
    instance = find_by(to_find)
    instance ?
      instance.update_attributes(to_update) : create(to_find.merge(to_update))
  end
end
