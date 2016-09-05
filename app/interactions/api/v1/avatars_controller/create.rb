class Api::V1::AvatarsController::Create < Api::BaseInteraction
  object :user
  object :avatar, class: ActionDispatch::Http::UploadedFile
  string :use_as_thumbnail

  def execute
    previous_timestamp = user.avatar_timestamp
    current_timestamp = DateTime.now.strftime('%Q')
    upload_avatar(current_timestamp)
    update_user(current_timestamp)
    compose(namespace::Common::DeleteAvatar, user: user, timestamp: previous_timestamp)
    @avatar = nil # remove avatar from inputs logging
  end

  private

  def update_user(timestamp)
    user.update_attributes(
      avatar_timestamp: timestamp,
      avatar_use_as_thumbnail: use_as_thumbnail)
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
