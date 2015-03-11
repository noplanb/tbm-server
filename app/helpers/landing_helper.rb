module LandingHelper
  def app_name
    APP_CONFIG[:app_name]
  end

  def iphone_store_url
    APP_CONFIG[:iphone_store_url]
  end

  def android_store_url
    APP_CONFIG[:android_store_url]
  end

end
