class Api::V1::AvatarsController::Shared::DeleteAvatar < Api::BaseInteraction
  object :user
  string :timestamp, default: nil

  def execute
    Aws::S3::Client.new.delete_object(
      bucket: S3Credential::Avatars.instance.cred['bucket'],
      key: "#{user.mkey}_#{timestamp}") if timestamp
  end
end
