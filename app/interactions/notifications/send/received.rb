class Notifications::Send::Received < Notifications::Send
  def execute
    send_notification
    trigger_event(%w(video notification received))
  end

  private

  def notification_receiver
    receiver
  end

  def base_notification
    { type: :alert,
      alert: "New message from #{sender.name}",
      badge: 1 }
  end

  def payload_with_legacy_schema
    { type: 'video_received',
      from_mkey: sender.mkey,
      video_id: message.message_id,
      host: host }
  end

  def payload_with_new_schema
    { type: 'message_received',
      content_type: message.type,
      from_mkey: sender.mkey,
      owner_mkey: receiver.mkey,
      message_id: message.message_id,
      host: host }.merge(message.stripped_value.symbolize_keys)
  end
end
