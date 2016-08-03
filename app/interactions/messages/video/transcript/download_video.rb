class Messages::Video::Transcript::DownloadVideo < ActiveInteraction::Base
  string :file_path
  object :s3_event

  def execute
    video_path = file_path + '.mp4'
    s3_client.get_object(
      response_target: video_path,
      bucket: s3_event.bucket_name,
      key: s3_event.file_name)
    video_path
  end

  private

  def s3_client
    @s3_client ||= Aws::S3::Client.new(
      access_key_id: Figaro.env.s3_access_key_id,
      secret_access_key: Figaro.env.s3_secret_access_key)
  end
end
