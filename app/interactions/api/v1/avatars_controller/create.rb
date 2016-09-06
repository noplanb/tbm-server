class Api::V1::AvatarsController::Create < Api::BaseInteraction
  object :user
  object :avatar, class: ActionDispatch::Http::UploadedFile
  string :use_as_thumbnail

  def execute
    previous_timestamp = user.avatar_timestamp
    current_timestamp = DateTime.now.strftime('%Q')
    upload_avatar(current_timestamp)
    update_user(current_timestamp)
    delete_avatar(previous_timestamp)
    @avatar = nil # remove avatar from inputs logging
  end

  private

  def upload_avatar(timestamp)
    compose(namespace::Shared::UploadAvatar,
      user: user, tempfile: avatar.tempfile, timestamp: timestamp)
  end

  def delete_avatar(timestamp)
    compose(namespace::Shared::DeleteAvatar,
      user: user, timestamp: timestamp)
  end

  def update_user(timestamp)
    user.update_attributes(
      avatar_timestamp: timestamp,
      avatar_use_as_thumbnail: use_as_thumbnail)
  end
end
