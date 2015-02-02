class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  REALM = "zazo.com"
  
  # ==================
  # = Before filters =
  # ==================
  def authenticate
    debugger
    authenticate_or_request_with_http_digest(REALM) do |mkey|
      debugger
      @user = User.find_by_mkey(mkey)
      @user && @user.auth 
    end
  end

end
