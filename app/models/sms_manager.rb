class SmsManager
  require 'twilio-ruby'

  def initialize
    @twilio = Twilio::REST::Client.new Figaro.env.twilio_ssid, Figaro.env.twilio_token
  end

  def send_sms(to, msg)
    @twilio.messages.create(from: Figaro.env.twilio_from_number, to: to, body: msg)
  end

  def send_verification_sms(user)
    user.reset_verification_code
    to = Rails.env.development? ? Figaro.env.twilio_to_number : user.mobile_number
    msg = "#{APP_CONFIG[:app_name]} access code: #{user.verification_code}"
    send_sms(to, msg)
    Rails.logger.info "send_verification_sms: to:#{to} msg:#{msg}"
  end
end
