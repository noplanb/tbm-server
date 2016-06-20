class Kvstore::TriggerEvent
  attr_reader :object
  attr_reader :sender, :receiver, :value

  def initialize(object)
    @object = object
    set_object_variables
  end

  def call
    return false if object.key1.blank? && object.value.blank?
    return false unless Kvstore::SUFFIXES_FOR_EVENTS.any? do |suffix|
      object.key1.include?(suffix)
    end

    type = value['type'] || 'video'
    status = value.fetch('status', 'received')
    name = [type, object.class.name.underscore, status]
    EventDispatcher.emit(name, build_event(type))
  end

  private

  def set_object_variables
    sender_id, receiver_id, _hash, _type = object.key1.split('-')
    @sender = User.find_by_mkey(sender_id)
    @receiver = User.find_by_mkey(receiver_id)
    @value = JSON.parse(object.value)
  end

  def build_event(type)
    target_id = case type
      when 'text' then value['messageId']
      else video_filename
    end

    { initiator: 'user',
      initiator_id: sender.mkey,
      target: type,
      target_id: target_id,
      data: build_event_data(type),
      raw_params: object.attributes.slice('key1', 'key2', 'value') }
  end

  def build_event_data(type)
    additions = case type
      when 'text'
        { message_id: value['messageId'] }
      else
        { video_filename: video_filename,
          video_id: value['videoId'] }
    end

    { sender_id: sender.mkey,
      sender_platform: sender.try(:device_platform),
      receiver_id: receiver.mkey,
      receiver_platform: receiver.try(:device_platform) }.merge(additions)
  end

  #
  # type specific helpers
  #

  def video_filename
    @video_filename ||= object.class.video_filename(sender, receiver, value['videoId'])
  end
end
