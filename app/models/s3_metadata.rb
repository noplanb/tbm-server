class S3Metadata
  include ActiveModel::Validations

  attr_accessor :client_version, :client_platform,
                :sender_mkey, :receiver_mkey, :video_id

  validates_presence_of :client_version, :client_platform,
                        :sender_mkey, :receiver_mkey, :video_id

  def self.create_by_event(s3_event)
    instance = new FetchMetadata.new(s3_event).do
    instance = new unless instance.valid?
    instance
  rescue S3Metadata::FetchMetadata::IncorrectEventData
    new
  end

  def initialize(attrs = {})
    self.client_version  = attrs['client-version'].to_i
    self.client_platform = attrs['client-platform']
    self.sender_mkey     = attrs['sender-mkey']
    self.receiver_mkey   = attrs['receiver-mkey']
    self.video_id        = attrs['video-id']
  end

  def inspect
    { client_version: client_version,
      client_platform: client_platform,
      sender_mkey: sender_mkey,
      receiver_mkey: receiver_mkey,
      video_id: video_id }.inspect
  end
end
