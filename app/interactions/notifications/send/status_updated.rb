class Notifications::Send::StatusUpdated < Notifications::Send
  private

  def notification_receiver
    sender
  end

  def base_notification
    { type: :silent }
  end

  def payload_with_legacy_schema
    { type: 'video_status_update',
      to_mkey: receiver.mkey,
      status: message.status,
      video_id: message.message_id,
      host: host }
  end

  def payload_with_new_schema
    { type: 'message_status_update',
      content_type: message.type,
      to_mkey: receiver.mkey,
      owner_mkey: sender.mkey,
      status: message.status,
      message_id: message.message_id,
      host: host }
  end
end
