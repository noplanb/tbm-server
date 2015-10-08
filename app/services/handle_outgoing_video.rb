class HandleOutgoingVideo
  attr_reader :s3_event

  def initialize(s3_event_params)
    @s3_event = S3Event.new s3_event_params


  end

  def do
    s3_event.valid?
  end

  def errors
    s3_event.errors.messages
  end
end
