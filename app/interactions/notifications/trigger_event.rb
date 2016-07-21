class Notifications::TriggerEvent < ActiveInteraction::Base
  object :caller, class: Notifications::Send

  def execute
    EventDispatcher.emit(name, event)
  end

  private

  def name
    [caller.message.type, 'notification', caller.message.status]
  end

  def event
    base_event = {
      initiator: 'user',
      initiator_id: caller.sender.mkey,
      data: {
        sender_id: caller.sender.mkey,
        sender_platform: caller.sender.device_platform,
        receiver_id: caller.receiver.mkey,
        receiver_platform: caller.receiver.device_platform }}
    send("build_event_by_#{caller.message.type}_message", base_event)
  end

  def build_event_by_video_message(event)
    video_filename = Kvstore.video_filename(
      caller.sender.mkey, caller.receiver.mkey, caller.message.message_id)
    event[:target] = 'video'
    event[:target_id] = video_filename
    event[:data][:video_filename] = video_filename
    event[:data][:video_id] = caller.message.message_id
    event
  end

  def build_event_by_text_message(event)
    event[:target] = 'text'
    event[:target_id] = caller.message.message_id
    event[:data][:message_id] = caller.message.message_id
    event
  end
end
