class Message < ActiveRecord::Base
  validates :sender, :receiver, :message_id, :message_type, presence: true

  def self.create_or_update(to_find, to_update)
    instance = find_by(to_find)
    instance ?
      instance.update_attributes(to_update) : create(to_find.merge(to_update))
  end
end
