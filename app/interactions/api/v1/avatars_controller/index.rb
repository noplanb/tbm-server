class Api::V1::AvatarsController::Index < Api::BaseInteraction
  object :user

  def execute
    { timestamp: user.avatar_timestamp,
      use_as_thumbnail: user.avatar_use_as_thumbnail }
  end
end
