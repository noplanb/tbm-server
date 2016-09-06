class Api::V1::AvatarsController::Shared::UploadAvatar < Api::BaseInteraction
  object :user
  object :tempfile
  string :timestamp

  def execute
    aws_s3_resource
      .bucket(Figaro.env.s3_avatars_bucket)
      .object("#{user.mkey}_#{timestamp}")
      .upload_file(tempfile)
  end

  private

  def aws_s3_resource
    Aws::S3::Resource.new(
      access_key_id: Figaro.env.s3_access_key_id,
      secret_access_key: Figaro.env.s3_secret_access_key)
  end
end
