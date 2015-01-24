class DispatchController < ApplicationController
  include NpbNotification
  
  before_filter :authenticate
  
  def post_dispatch    
    subject = "ZAZO #{@user.device_platform} ERROR: #{params[:msg].lines.first}"
    msg = "#{@user.inspect} \n\n\n #{params[:msg]}"
    npb_mail msg, subject:subject
    render json: {status:"success"}
  end
  
end