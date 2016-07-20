class VersionController < ApplicationController
  def check_compatibility
    #Users::SaveDeviceInfo.run(user: current_user, platform: params[:device_platform], version: params[:version])
    version_compatibility = VersionCompatibility.instance
    render json: { result: version_compatibility.compatibility(params[:device_platform],
                                                               params[:version]) }
  end
end
