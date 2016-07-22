class ApplicationController < ActionController::Base
  REALM = 'zazo.com'

  attr_reader :current_user
  helper_method :current_user

  def authenticate
    authenticate_or_request_with_http_digest(REALM) do |mkey|
      @user = @current_user = User.find_by_mkey(mkey)
      fail(ActiveRecord::RecordNotFound, "user with mkey='#{mkey}' not found") if !@user && Rails.env.staging?
      @user && @user.auth
    end
  end

  def save_client_info
    Users::SaveClientInfo.run(
      user: current_user,
      device_platform: request.headers['Device-Platform'],
      device_info: request.headers['Device-Info'],
      app_version: request.headers['App-Version'])
  end

  def not_found
    fail ActionController::RoutingError.new('Not Found')
  end
end
