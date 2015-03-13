module LandingHelper
  # ==============================
  # = User Agent related methods =
  # ==============================
  def mobile_device?
    request.user_agent =~ /mobile|webos/i
  end

  def android?
    request.user_agent =~ /android/i
  end

  def ios?
    request.user_agent =~ /ios/i
  end

  def app_name
    APP_CONFIG[:app_name]
  end

  def iphone_store_url
    APP_CONFIG[:iphone_store_url]
  end

  def android_store_url
    APP_CONFIG[:android_store_url]
  end

  def store_url
    ios? ? iphone_store_url : android_store_url
  end
end
