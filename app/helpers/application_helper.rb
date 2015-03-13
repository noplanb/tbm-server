module ApplicationHelper
  def status_tag(status)
    content_tag :span, status, class: ['status', status]
  end

  def human_device_platform(platform)
    t(platform, scope: :device_platforms)
  end
end
