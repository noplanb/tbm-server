class DispatchController < ApplicationController
  before_action :authenticate

  def post_dispatch
    report = params[:msg]
    error_message = report.match(/(^[a-z]+(.+)$)/i) do |m|
      m[0]
    end
    notifier = Rollbar.scope(
      person: {
        id: @user.id,
        username: @user.name,
        email: @user.mobile_number })
    notifier.configuration.access_token = Figaro.env.send "#{@user.device_platform.to_s.downcase}_rollbar_access_token"
    notifier.error(error_message)
    render json: { status: 'success' }
  end
end
