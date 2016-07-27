class Messages::TriggerEvent < ActiveInteraction::Base
  object :sender,   class: ::User
  object :receiver, class: ::User
  object :message,  class: ::Kvstore.decorator(:default)
  string :type

  def execute
    Zazo::Tool::EventDispatcher.emit(name, event)
  end

  private

  def name
    [message.type, type, message.status]
  end

  def event
    base_event = {
      initiator: 'user',
      initiator_id: sender.mkey,
      data: {
        sender_id: sender.mkey,
        sender_platform: sender.device_platform,
        receiver_id: receiver.mkey,
        receiver_platform: receiver.device_platform },
      raw_params: message.model.attributes.slice('key1', 'key2', 'value') }
    send("build_event_by_#{message.type}_message", base_event)
  end

  def build_event_by_video_message(event)
    video_filename = Kvstore.video_filename(
      sender.mkey, receiver.mkey, message.message_id)
    event[:target] = 'video'
    event[:target_id] = video_filename
    event[:data][:video_filename] = video_filename
    event[:data][:video_id] = message.message_id
    event
  end

  def build_event_by_text_message(event)
    event[:target] = 'text'
    event[:target_id] = message.message_id
    event[:data][:message_id] = message.message_id
    event
  end
end
