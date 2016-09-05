class Api::V1::AvatarsController::Create < Api::BaseInteraction
  object :user
  object :avatar, class: ActionDispatch::Http::UploadedFile
  string :use_as_thumbnail

  def execute
    #delete_avatar(user.avatar_timestamp)
    timestamp = Time.now.to_i
    upload_avatar(timestamp)
    @avatar = nil # remove this from inputs logging
  end

  private

  def delete_avatar(timestamp)

  end

  def upload_avatar(timestamp)
    object = aws_s3_resource.bucket(Figaro.env.s3_avatars_bucket).object("#{user.mkey}_#{timestamp}")
    object.upload_file(avatar.tempfile)
  end

  def aws_s3_resource
    Aws::S3::Resource.new(
      access_key_id: Figaro.env.s3_access_key_id,
      secret_access_key: Figaro.env.s3_secret_access_key)
  end
end
