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
    # update kv-store with video_id
    # send notification to receiver
  end

  def client_version_correspond?
    return true if s3_metadata.client_platform == 'android' && s3_metadata.client_version >= 110
    false
  end
end
