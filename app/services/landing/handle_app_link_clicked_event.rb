class Landing::HandleAppLinkClickedEvent
  include Rails.application.routes.url_helpers

  attr_reader :user_agent, :additions

  def initialize(user_agent, additions)
    @user_agent = DeviceByUserAgent.new user_agent
    @additions  = additions
  end

  def do
    platform, redirect_path = get_platform_and_path
    fire_sqs_event platform
    yield redirect_path if block_given?
  end

  def get_platform_and_path
    platform, redirect_path = :unknown, nil
    if user_agent.android? && user_agent.ios?
      platform, redirect_path = :mobile_device, root_path
      send_warning 'Both iOS and Android detected'
    elsif user_agent.android?
      platform, redirect_path = :android, Settings.android_store_url
    elsif user_agent.ios?
      platform, redirect_path = :ios, Settings.iphone_store_url
    elsif user_agent.mobile_device?
      platform, redirect_path = :mobile_device, root_path
      send_warning 'Unsupported User Agent detected'
    end
    return platform, redirect_path
  end

  private

  def fire_sqs_event(platform)
    Zazo::Tool::EventDispatcher.emit(%w(user app_link_clicked),
      initiator: 'user',
      data: { platform: platform }.merge(sqs_event_data),
      raw_params: { user_agent: user_agent.raw })
  end

  def sqs_event_data
    data = {}
    data.merge!({
      link_key: 'c',
      connection_id: additions[:connection].id,
      connection_creator_mkey: additions[:connection].creator.mkey,
      connection_target_mkey: additions[:connection].target.mkey,
    }) if additions[:connection]
    data.merge!({
      link_key: 'l',
      inviter_id: additions[:inviter].id,
      inviter_mkey: additions[:inviter].mkey,
    }) if additions[:inviter]
    data
  end

  def send_warning(message)
    Rollbar.warning message, user_agent: user_agent.raw
  end
end
