class S3Metadata::FetchMetadata
  class IncorrectEventData < Exception; end

  attr_reader :s3_client, :s3_event

  def initialize(s3_event)
    @s3_event  = s3_event
    @s3_client = s3_client_instance
  end

  def do
    s3_client.head_object(bucket: s3_event.bucket_name, key: s3_event.file_name).metadata
  rescue Aws::S3::Errors::Http301Error
    fail IncorrectEventData
  end

  private

  def s3_client_instance
    Aws::S3::Client.new(access_key_id: Figaro.env.s3_access_key_id,
                        secret_access_key: Figaro.env.s3_secret_access_key)
  end
end
