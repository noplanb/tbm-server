require 'digest/md5'
class DigestController < ApplicationController
  REALM = "zazo.com"
  USERS = {"username" => "password", #plain text password
           "dap" => Digest::MD5.hexdigest(["dap",REALM,"secret"].join(":"))}  #ha1 digest password

  before_action :authenticate, except: [:open]

  def open
    puts "open"
    render json: {message: "Open anyone can get this!"}
  end

  def secure
    msg = "Nicely done. You gained secure access from a browser. Now try from a mobile application"
    random_word = %w{dog cat mouse beet sugar help sound carry over under above frankly}.sample
    msg = "Well done Serhii! You got in from android! I am impressed that you succeeded with something you haven't done before! Random:#{random_word}" if /android/i =~ request.env["HTTP_USER_AGENT"]
    
    render json: {message: msg}
  end

  private
  def verify_user
    set_user
    if @user.blank? || @user.auth != params[:auth] 
      render nothing: true, status: :unauthorized
      return false
    end
    true
  end
  
  def set_user
    @user = User.find_by_mkey(params[:mkey])
  end
  
  def authenticate
    authenticate_or_request_with_http_digest(REALM) do |username|
      USERS[username]
    end
  end
end