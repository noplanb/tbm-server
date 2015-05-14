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
    request.user_agent =~ /ios|iphone|ipad|ipod/i
  end

  def windows_phone?
    request.user_agent =~ /windows phone/i
  end

  def app_name
    Settings.app_name
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
end
