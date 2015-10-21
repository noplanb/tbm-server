class DeviceByUserAgent
  MOBILE_REGEXP = /mobile|webos/i
  ANDROID_REGEXP = /android/i
  IOS_REGEXP = /ios|iphone|ipad|ipod/i
  WINDOWS_PHONE_REGEXP = /windows phone/i

  attr_accessor :user_agent
  alias_method  :raw, :user_agent

  def initialize(user_agent)
    self.user_agent = user_agent.to_s
  end

  def mobile_device?
    match?(MOBILE_REGEXP)
  end

  def android?
    match?(ANDROID_REGEXP) && !match?(WINDOWS_PHONE_REGEXP) && !match?(IOS_REGEXP)
  end

  def ios?
    match?(IOS_REGEXP) && !match?(WINDOWS_PHONE_REGEXP) && !match?(ANDROID_REGEXP)
  end

  def windows_phone?
    match?(WINDOWS_PHONE_REGEXP)
  end

  private

  def match?(regexp)
    !user_agent.match(regexp).nil?
  end
end
