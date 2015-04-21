class VerificationCodeController < ApplicationController
  def say_code
    user = params[:To] && User.find_by_raw_mobile_number(params[:To])
    code = user && user.get_verification_code
    if code
      render xml: code_twml(code).to_xml
    else
      err = "VerificationCodeController#say_code user or code not found. For to:#{params[:To]} This should never happen."
      Rollbar.error err
      Rails.logger.error err
      render xml: error_twml.to_xml
    end
  end

  def call_fallback
    message = 'Error on call with Twilio'
    Rails.logger.error("VerificationCodeController#call_fallback: #{message}, params: #{params}")
    Rollbar.error(message)
    render nothing: true
  end

  private

  def code_twml(code)
    Twilio::TwiML::Response.new do |r|
      r.Say 'zah-zo code', voice: 'man', language: 'en'
      r.Pause
      code.each_char do |char|
        r.Pause
        r.Say char
      end
      r.Pause length: 2
      r.Say 'repeating'
      code.each_char do |char|
        r.Pause
        r.Say char
      end
      r.Pause length: 2
      r.Say 'goodbye'
    end
  end

  def error_twml
    Twilio::TwiML::Response.new do |r|
      r.Say 'zah-zo error while retrieving your verification code', voice: 'man', language: 'en'
    end
  end
end
