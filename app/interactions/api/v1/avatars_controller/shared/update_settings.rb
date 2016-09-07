class Api::V1::AvatarsController::Shared::UpdateSettings < Api::BaseInteraction
  object :user
  string :timestamp, default: nil
  string :use_as_thumbnail

  validates :use_as_thumbnail, inclusion: {
    in: %w(avatar last_frame), message: '%{value} is not allowed' }

  def execute
    user.avatar_timestamp = timestamp if timestamp
    user.avatar_use_as_thumbnail = use_as_thumbnail
    user.save
  end
end
