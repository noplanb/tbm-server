class Api::V1::AvatarsController::Destroy < Api::BaseInteraction
  object :user

  def execute
    compose(namespace::Shared::DeleteAvatar, user: user, timestamp: user.avatar_timestamp)
    user.update_attributes(
      avatar_timestamp: nil,
      avatar_use_as_thumbnail: nil)
  end
end
