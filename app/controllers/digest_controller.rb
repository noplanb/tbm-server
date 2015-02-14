class DigestController < ApplicationController
  before_filter :digest_auth, only: :secure
  REALM = "zazo.com"
  
  def open
    render json: {message: "this action is open"}
  end
  
  def secure
    render json: {username: @username, message: "this action is secure. you got in"}
  end
  
  def digest_auth
    authenticate_or_request_with_http_digest(REALM) do |username|
      @username = username
      "password"
    end
  end
end
