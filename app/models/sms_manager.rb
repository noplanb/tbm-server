class SmsManager
  def send_verification_sms(user)
    user.reset_verification_code
    send_sms(to(user), message(user))
  end

  def from
    Figaro.env.twilio_from_number
  end

  def to(user)
    Rails.env.development? ? Figaro.env.twilio_to_number : user.mobile_number
  end

  def message(user)
    "#{APP_CONFIG[:app_name]} access code: #{user.verification_code}"
  end

  def twilio_invalid_number?(code)
    [21211, 21214, 21217, 21219, 21401, 21407, 21421, 21614].include?(code.to_i)
  end

  def send_sms(to, message)
    @twilio = Twilio::REST::Client.new Figaro.env.twilio_ssid, Figaro.env.twilio_token
    @twilio.messages.create(from: from, to: to, body: message)
    Rails.logger.info "send_verification_sms: to:#{to} msg:#{message}"
    0
  rescue Twilio::REST::RequestError => error
    Rails.logger.error "ERROR: reg/reg: #{error.class} ##{error.code}: #{error.message}"
    twilio_invalid_number?(error.code) ? 1 : 2
  end
end
