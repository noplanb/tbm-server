class Api::V1::AvatarsController::Shared::DeleteAvatar < Api::BaseInteraction
  object :user
  string :timestamp, default: nil

  def execute
    aws_s3_client.delete_object(
      bucket: Figaro.env.s3_avatars_bucket,
      key: "#{user.mkey}_#{timestamp}") if timestamp
  end

  private

  def aws_s3_client
    Aws::S3::Client.new(
      access_key_id: Figaro.env.s3_access_key_id,
      secret_access_key: Figaro.env.s3_secret_access_key)
  end
end
