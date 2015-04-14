class DispatchController < ApplicationController
  before_action :authenticate

  def post_dispatch
    notifier = Rollbar.scope(
      person: {
        id: @user.id,
        username: @user.name,
        email: @user.mobile_number })
    notifier.configuration.access_token = Figaro.env.send "#{@user.device_platform.to_s.downcase}_rollbar_access_token"
    notifier.error(error_message(params[:msg]))
    render json: { status: 'success' }
  end

  def error_message(report)
    report.match(/(^[a-z]+(.+)$)/i) do |m|
      m[0]
    end.presence || 'Dispatch Message'
  end
end
