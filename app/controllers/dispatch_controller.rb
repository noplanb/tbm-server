class DispatchController < ApplicationController
  include NpbNotification
  
  skip_before_filter :verify_authenticity_token
  before_filter :verify_user
  
  def post_dispatch
    set_user
    
    first_line = params[:msg].match(/(^.*)\n/)[1]
    subject = "ZAZO #{@user.device_platform} client error: #{first_line}"
    msg = "#{@user.inspect} \n\n\n #{params[:msg]}"
    npb_mail msg, subject:subject
    render json: {status:"success"}
  end
  
end