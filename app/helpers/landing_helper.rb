module LandingHelper
  def android?
    DeviceByUserAgent.new(request.user_agent).android?
  end

  def ios?
    DeviceByUserAgent.new(request.user_agent).ios?
  end

  def iphone_store_url
    Settings.iphone_store_url
  end

  def android_store_url
    Settings.android_store_url
  end

  def store_url
    ios? ? iphone_store_url : android_store_url
  end

  def app_name
    Settings.app_name
  end
end
