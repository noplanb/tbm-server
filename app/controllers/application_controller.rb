class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  REALM = "zazo.com"
  
  # ==================
  # = Before filters =
  # ==================
  def authenticate
    authenticate_or_request_with_http_digest(REALM) do |mkey|
      @user = User.find_by_mkey(mkey)
      @user && @user.auth 
    end
  end
  
  # ==============================
  # = User Agent related methods =
  # ==============================
  def mobile_device?
    return request.user_agent =~ /mobile|webos/i
  end
  
  def android?
    return request.user_agent =~ /android/i
  end

  def ios?
    return request.user_agent =~ /ios/i
  end
  
  def store_link
    android? ? APP_CONFIG[:android_store_link] : APP_CONFIG[:iphone_store_link]
  end
end
