class HandleOutgoingVideo
  attr_reader :s3_event, :s3_metadata

  def initialize(s3_event_params)
    @s3_event = S3Event.new s3_event_params
  end

  def do
    return false unless s3_event.valid?
    @s3_metadata = S3Metadata.create_by_event s3_event
    handle_outgoing_video if client_version_correspond?
    true
  end

  def errors
    s3_event.errors.messages
  end

  private

  def handle_outgoing_video
    update_kvstore_with_video_id
    send_notification_to_receiver
  end

  def update_kvstore_with_video_id
    Kvstore.create_or_update key1: "#{s3_event.file_name}-VideoIdKVKey", key2: s3_metadata.video_id,
                             value: { 'videoId' => s3_metadata.video_id }.to_json
  end

  def send_notification_to_receiver

  end

  def client_version_correspond?
    return true if s3_metadata.client_platform == 'android' && s3_metadata.client_version >= 110
    false
  end
end
