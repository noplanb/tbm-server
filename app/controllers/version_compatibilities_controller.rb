class VersionCompatibilitiesController < ApplicationController
  http_basic_authenticate_with name: Figaro.env.http_basic_username, password: Figaro.env.http_basic_password, except: :info

  before_action :set_version_compatibility

  # GET /version_compatibilities
  def index
    redirect_to @version_compatibility
  end

  # GET /version_compatibilities/1
  def show
  end

  # GET /version_compatibilities/1/edit
  def edit
  end

  # PATCH/PUT /version_compatibilities/1
  def update
    if @version_compatibility.update_credentials(version_compatibility_params)
      redirect_to @version_compatibility, notice: 'Version compatibility was successfully updated.'
    else
      render :edit
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_version_compatibility
    @version_compatibility = VersionCompatibility.instance
  end

  # Only allow a trusted parameter "white list" through.
  def version_compatibility_params
    params.require(:version_compatibility).permit(*VersionCompatibility.credential_attributes)
  end
end
