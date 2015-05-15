class VersionController < ApplicationController
  def check_compatibility
    version_compatibility = VersionCompatibility.instance
    render json: { result: version_compatibility.compatibility(params[:device_platform],
                                                               params[:version]) }
  end
end
