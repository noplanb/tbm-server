class Api::V1::AvatarsController::Shared::UploadAvatar < Api::BaseInteraction
  object :user
  object :tempfile
  string :timestamp

  def execute
    Aws::S3::Resource.new
      .bucket(S3Credential::Avatars.instance.cred['bucket'])
      .object("#{user.mkey}_#{timestamp}")
      .upload_file(tempfile)
  end
end
