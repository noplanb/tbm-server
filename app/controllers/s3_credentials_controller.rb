class S3CredentialsController < ApplicationController
  http_basic_authenticate_with(
    name: Figaro.env.http_basic_username,
    password: Figaro.env.http_basic_password,
    except: [:info, :videos, :avatars])
  before_action :set_s3_credential, only: [:index, :show, :edit, :update]
  before_action :authenticate, only: [:info, :videos, :avatars]

  # =====================
  # = Mobile client api =
  # =====================

  def info
    videos
  end

  def videos
    render_app_attributes(:videos)
  end

  def avatars
    render_app_attributes(:avatars)
  end

  # ================
  # = Admin screen =
  # ================

  def index
  end

  def show
  end

  def edit
  end

  def update
    if @s3_credential.update_credentials(s3_credential_params(params[:id]))
      redirect_to s3_credential_url(params[:id]), notice: 'S3 info was successfully updated.'
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
