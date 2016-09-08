class S3CredentialsController < ApiController
  def info
    videos
  end

  def videos
    render_app_attributes(:videos)
  end

  def avatars
    render_app_attributes(:avatars)
  end

  private

  def render_app_attributes(type)
    render json: { status: 'success' }.merge(S3Credential.by_type(type).only_app_attributes)
  end
end
