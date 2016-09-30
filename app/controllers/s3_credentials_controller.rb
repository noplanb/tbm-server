class S3CredentialsController < ApiController
  def info
    videos
  end

  def videos
    render_client_credentials(:videos)
  end

  def avatars
    render_client_credentials(:avatars)
  end

  private

  def render_client_credentials(type)
    render json: { status: 'success' }.merge(S3Credential.by_type(type).only_app_attributes)
  end
end
