module ApplicationHelper
  def status_tag(status)
    content_tag :span, status, class: ['status', status]
  end
end
