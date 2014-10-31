class SmsManager
  require 'twilio-ruby'

  def initialize
    @twilio = Twilio::REST::Client.new APP_CONFIG[:twilio_ssid], APP_CONFIG[:twilio_token] 
  end

  def send_sms(to, msg)
    @twilio.messages.create(from:APP_CONFIG[:twilio_from_number] , to: to, body: msg)
  end
  
  def send_verification_sms(user)
    user.reset_verification_code
    to = Rails.env == "development" ? APP_CONFIG[:twilio_to_number] : user.mobile_number
    msg = "#{APP_CONFIG[:app_name]} access code: #{user.verification_code}"
    send_sms(to, msg)
  end
end
