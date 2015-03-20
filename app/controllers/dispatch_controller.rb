class DispatchController < ApplicationController
  before_action :authenticate

  def post_dispatch
    error_message = params[:msg].lines.first.chomp
    backtrace = params[:msg]
    api_key = Figaro.env.send "#{@user.device_platform.to_s.downcase}_airbrake_api_key"
    Airbrake.notify(error_message: error_message, backtrace: backtrace, api_key: api_key)
    render json: { status: 'success' }
  end
end
