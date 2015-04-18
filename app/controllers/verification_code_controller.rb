class VerificationCodeController < ApplicationController

  def say_code
    user = params[:To] && User.find_by_raw_mobile_number(params[:To])
    code = user && user.get_verification_code
    if code
      render :xml => code_twml(code)
    else
      err = "VerificationCodeController#say_code user or code not found. For to:#{params[:To]} This should never happen."
      Rollbar.error err
      Rails.logger.error err
      render :xml => error_twml
    end
  end

  private

  def code_twml(code)
    sc = spaced_code code
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.Response {
        xml.Say('zah-zo code', voice: 'man', language:'en')
        xml.Pause
        xml.Say(sc)
        xml.Pause(length: 2)
        xml.Say("repeat #{sc}")
        xml.Pause(length: 3)
        xml.Say("repeat #{sc}")
        xml.Pause
        xml.Say('goodbye')
      }
    end
  end

  def error_twml
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.Response {
        xml.Say('zah-zo error while retrieving your verification code', voice: 'man', language:'en')
      }
    end
  end

  def spaced_code(code)
    " #{code.each_char.to_a.join(" ")} "
  end

end