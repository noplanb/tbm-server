class S3CredentialsController < ApplicationController
  http_basic_authenticate_with name: Figaro.env.http_basic_username, password: Figaro.env.http_basic_password
  before_action :authenticate, only: :info

  # =====================
  # = Mobile client api =
  # =====================
  def info
    render json: { status: 'success' }.merge(S3Credential.instance.only_app_attributes)
  end

  # ================
  # = Admin screen =
  # ================
  before_action :set_s3_credential, only: [:index, :show, :edit, :update]

  def index
    redirect_to @s3_credential
  end

  # GET /s3_credentials/1
  def show
  end

  # GET /s3_credentials/1/edit
  def edit
  end

  # PATCH/PUT /s3_credentials/1
  def update
    respond_to do |format|
      if @s3_credential.update(s3_credential_params)
        format.html { redirect_to @s3_credential, notice: 'S3 info was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  private

  def set_s3_credential
    @s3_credential = S3Credential.instance
  end

  def s3_credential_params
    params.require(:s3_credential).permit(:region, :bucket, :access_key, :secret_key)
  end
end
