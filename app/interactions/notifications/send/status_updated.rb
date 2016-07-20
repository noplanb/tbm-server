class Notifications::Send::StatusUpdated < Notifications::Send
  def execute
    send_notification
    trigger_event(%w(video notification) + [message.status])
  end

  private

  def send_notification
    payload = new_schema_allowed?(receiver) ?
      payload_with_new_schema : payload_with_legacy_schema
    sender.push_user.try(:send_notification,
      base_notification.merge(payload: payload))
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
    { type: 'video_status_update',
      content_type: message.type,
      to_mkey: receiver.mkey,
      owner_mkey: sender.mkey,
      message_id: message.message_id,
      host: host }
  end
end
