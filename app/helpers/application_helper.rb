module ApplicationHelper
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

  def store_url
    android? ? APP_CONFIG[:android_store_url] : APP_CONFIG[:iphone_store_url]
  end

  def status_tag(status)
    content_tag :span, status, class: ['status', status]
  end

  def human_device_platform(platform)
    t(platform, scope: :device_platforms)
  end
end
