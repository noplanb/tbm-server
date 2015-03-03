class VersionController < ApplicationController

  def check_compatibility
    v = params[:version].to_i
    r = "error"
    r = is_android? ? get_android_response(v) : get_ios_response(v)
    render :json => {result: r}
  end

  def get_ios_response(v)
    if false
      return "update_schema_required"
    elsif v < 18
      return "update_required"
    elsif false
      return "update_optional"
    else
      return "current"
    end
  end

  def get_android_response(v)
    if false
      return "update_schema_required"
    elsif v < 37
      return "update_required"
    elsif false
       return"update_optional"
    else
      return "current"
    end
  end


  private

  def is_android?
    params[:device_platform].downcase.match("android")
  end

end