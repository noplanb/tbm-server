class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  REALM = 'zazo.com'

  MOBILE_REGEXP = /mobile|webos/i
  ANDROID_REGEXP = /android/i
  IOS_REGEXP = /ios|iphone|ipad|ipod/i
  WINDOWS_PHONE_REGEXP = /windows phone/i

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

  # ==============================
  # = User Agent related methods =
  # ==============================
  def mobile_device?
    !request.user_agent.to_s.match(MOBILE_REGEXP).nil?
  end

  def android?
    request.user_agent.to_s.match(WINDOWS_PHONE_REGEXP).nil? &&
      request.user_agent.to_s.match(IOS_REGEXP).nil? &&
      !request.user_agent.to_s.match(ANDROID_REGEXP).nil?
  end

  def ios?
    request.user_agent.to_s.match(WINDOWS_PHONE_REGEXP).nil? &&
      request.user_agent.to_s.match(ANDROID_REGEXP).nil? &&
      !request.user_agent.to_s.match(IOS_REGEXP).nil?
  end

  def windows_phone?
    !request.user_agent.to_s.match(WINDOWS_PHONE_REGEXP).nil?
  end

  def app_name
    Settings.app_name
  end

  def iphone_store_url
    Settings.iphone_store_url
  end

  def android_store_url
    Settings.android_store_url
  end

  def store_url
    ios? ? iphone_store_url : android_store_url
  end

  helper_method :ios?, :android?, :app_name, :iphone_store_url, :android_store_url, :store_url
end
