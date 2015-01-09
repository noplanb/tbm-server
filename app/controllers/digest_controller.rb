require 'digest/md5'
class DigestController < ApplicationController
  REALM = "zazo.com"
  USERS = {"username" => "password", #plain text password
           "dap" => Digest::MD5.hexdigest(["dap",REALM,"secret"].join(":"))}  #ha1 digest password

  before_action :authenticate, except: [:open]

  def open
    render json: {status: "Open anyone can see me!"}
  end

  def secure
    render json: {status: "Well done you gained secure access!"}
  end

  private
    def authenticate
      authenticate_or_request_with_http_digest(REALM) do |username|
        USERS[username]
      end
    end
end