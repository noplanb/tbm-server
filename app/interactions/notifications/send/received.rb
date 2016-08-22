class Notifications::Send::Received < Notifications::Send
  private

  def notification_receiver
    receiver
  end

  def base_notification
    { type: :alert,
      alert: notification_alert,
      category: 'MESSAGE_CATEGORY',
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

  def notification_alert
    if message.type?(:text)
     "#{sender.name}: #{message.value['body']}"
    else
      "New message from #{sender.name}"
    end
  end
end
