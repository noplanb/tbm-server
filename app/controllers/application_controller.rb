class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  REALM = 'zazo.com'

  attr_reader :current_user
  helper_method :current_user

  # ==================
  # = Before filters =
  # ==================

  def authenticate_with_digest
    authenticate_or_request_with_http_digest(REALM) do |mkey|
      @user = @current_user = User.find_by_mkey(mkey)
      fail(ActiveRecord::RecordNotFound, "user with mkey='#{mkey}' not found") if !@user && Rails.env.staging?
      @user && @user.auth
    end
  end

  def authenticate_with_basic
    authenticate_or_request_with_http_basic(REALM) do |username, password|
      @user = @current_user = User.find_by_mkey(username)
      @user.auth == password
    end
  end

  def authenticate_with_token
    authenticate_or_request_with_http_token do |token, _options|
      @user = @current_user = User.find_by_mkey(token)
      @user.present?
    end
  end

  def authentication_method
    Settings.authentication_method || :digest
  end

  def authenticate
    Rails.logger.debug "Trying authenticate with #{authentication_method.inspect}"
    send("authenticate_with_#{authentication_method}")
  end

  def notify_error(error)
    Rollbar.error(error)
  end

  def not_found
    fail ActionController::RoutingError.new('Not Found')
  end
end
