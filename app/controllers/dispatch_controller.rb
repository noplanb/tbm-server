class DispatchController < ApplicationController
  include NpbNotification
  
  skip_before_filter :verify_authenticity_token
  before_filter :authenticate
  
  def post_dispatch
    set_user
    
    subject = "ZAZO #{@user.device_platform} client error: #{params[:msg].lines.first}"
    msg = "#{@user.inspect} \n\n\n #{params[:msg]}"
    npb_mail msg, subject:subject
    render json: {status:"success"}
  end
  
end