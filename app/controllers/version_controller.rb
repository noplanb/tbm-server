class VersionController < ApplicationController
  before_action :authenticate

  def check_compatibility
    version_compatibility = VersionCompatibility.instance
    Users::SaveDeviceInfo.run(user: current_user, platform: params[:device_platform], version: params[:version])
    render json: { result: version_compatibility.compatibility(params[:device_platform], params[:version]) }
  end
end
