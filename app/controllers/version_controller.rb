class VersionController < ApplicationController
  before_action :authenticate

  def check_compatibility
    version_compatibility = VersionCompatibility.instance
    Users::SaveClientInfo.run(
      user: current_user, device_platform: params[:device_platform], app_version: params[:version])
    render json: { result: version_compatibility.compatibility(params[:device_platform], params[:version]) }
  end
end
