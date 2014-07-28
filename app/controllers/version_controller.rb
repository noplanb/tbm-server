class VersionController < ApplicationController
    
  def check_compatibility
    v = params[:version].to_i
    r = "error"
      
    if is_android?
      if v < 25
        r = "update_schema_required"
      elsif false
        r = "update_required"
      elsif false
        r = "update_optional"
      else
        r = "current"
      end
    else #ios
      if v < false
        r = "update_schema_required"
      elsif false
        r = "update_required"
      elsif false
        r = "update_optional"
      else
        r = "current"
      end
    end
    
    render :text => r
  end
  
  
  private
  
  def is_android?
    params[:device_platform].downcase.match("android")
  end
  
end