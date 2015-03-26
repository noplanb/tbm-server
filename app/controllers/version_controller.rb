class VersionController < ApplicationController
  def check_compatibility
    v = params[:version].to_i
    r = 'error'
    r = android? ? android_response(v) : ios_response(v)
    render json: { result: r }
  end

  private

  def ios_response(v)
    if false
      return 'update_schema_required'
    elsif v < 22
      return 'update_required'
    elsif false
      return 'update_optional'
    else
      return 'current'
    end
  end

  def android_response(v)
    if false
      return 'update_schema_required'
    elsif v < 42
      return 'update_required'
    elsif false
      return 'update_optional'
    else
      return 'current'
    end
  end

  def android?
    params[:device_platform].to_s.downcase.include?('android')
  end
end
