class SmsManager
  TWILIO_INVALID_NUMBER_ERRORS = {
    21211 => "Invalid 'To' Phone Number",
    21214 => "'To' phone number cannot be reached",
    21217 => "Phone number does not appear to be valid",
    21219 => "'To' phone number not verified",
    21401 => "Invalid Phone Number",
    21407 => "This Phone Number type does not support SMS or MMS",
    21421 => "PhoneNumber is invalid",
    21601 => "Phone number is not a valid SMS-capable/MMS-capable inbound phone number",
    21604 => "'To' phone number is required to send a Message",
    21612 => "The 'To' phone number is not currently reachable via SMS",
    21614 => "'To' number is not a valid mobile number",
    21615 => "PhoneNumber Requires a Local Address",
    21624 => "PhoneNumber Requires a Foreign Address",
  }

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
    TWILIO_INVALID_NUMBER_ERRORS.keys.include?(code.to_i)
  end

  def send_sms(to, message)
    @twilio = Twilio::REST::Client.new Figaro.env.twilio_ssid, Figaro.env.twilio_token
    @twilio.messages.create(from: from, to: to, body: message)
    Rails.logger.info "send_verification_sms: to:#{to} msg:#{message}"
    :ok
  rescue Twilio::REST::RequestError => error
    Rails.logger.error "ERROR: reg/reg: #{error.class} ##{error.code}: #{error.message}"
    twilio_invalid_number?(error.code) ? :invalid_mobile_number : :other
  end
end
