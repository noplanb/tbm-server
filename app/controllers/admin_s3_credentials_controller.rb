class AdminS3CredentialsController < AdminController
  before_action :set_s3_credential

  def index
  end

  def show
  end

  def edit
  end

  def update
    if @s3_credential.update_credentials(s3_credential_params(params[:id]))
      redirect_to admin_s3_credential_path(params[:id]), notice: 'S3 info was successfully updated.'
    else
      render action: 'edit'
    end
  end

  private

  def set_s3_credential
    @s3_credential = S3Credential.by_type(params[:id])
  end

  def s3_credential_params(type)
    params.require("s3_credential_#{type}").permit(:region, :bucket, :access_key, :secret_key)
  end

  def render_app_attributes(type)
    render json: { status: 'success' }.merge(S3Credential.by_type(type).only_app_attributes)
  end
end
