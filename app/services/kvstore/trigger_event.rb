class Kvstore::TriggerEvent
  attr_reader :object
  attr_reader :sender, :receiver, :value

  def initialize(object)
    @object = object
    set_object_variables
  end

  def call
    return false if object.key1.blank? && object.value.blank?
    return false unless Kvstore::SUFFIXES_FOR_EVENTS.any? { |suffix| object.key1.include?(suffix) }

    status = value.fetch('status', 'received')
    name = [target_name, object.class.name.underscore, status]
    EventDispatcher.emit(name, build_event)
  end

  private

  def set_object_variables
    sender_id, receiver_id, _hash, _type = object.key1.split('-')
    @sender = User.find_by_mkey(sender_id)
    @receiver = User.find_by_mkey(receiver_id)
    @value = JSON.parse(object.value)
  end

  def build_event
    case value['type']
      when 'text'
        target_id = value['messageId']
        data_additions = {
          message_id: value['messageId'] }
      when 'video'
        target_id = video_filename(value['messageId'])
        data_additions = {
          video_filename: target_id, video_id: value['messageId'] }
      else
        target_id = video_filename(value['videoId'])
        data_additions = {
          video_filename: target_id, video_id: value['videoId'] }
    end

    { initiator: 'user',
      initiator_id: sender.mkey,
      target: target_name,
      target_id: target_id,
      data: {
        sender_id: sender.mkey,
        sender_platform: sender.try(:device_platform),
        receiver_id: receiver.mkey,
        receiver_platform: receiver.try(:device_platform) }.merge(data_additions),
      raw_params: object.attributes.slice('key1', 'key2', 'value') }
  end

  #
  # type specific helpers
  #

  def target_name
    value['type'] || 'video'
  end

  def video_filename(message_id)
    object.class.video_filename(sender, receiver, message_id)
  end
end
