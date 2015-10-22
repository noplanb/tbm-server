class Landing::HandleAppLinkClickedEvent
  include Rails.application.routes.url_helpers

  attr_reader :user_agent, :connection_id

  def initialize(user_agent, connection_id)
    @user_agent    = DeviceByUserAgent.new user_agent
    @connection_id = connection_id
  end

  def do
    platform, redirect_path = get_platform_and_path
    fire_sqs_event platform
    yield redirect_path if block_given? && redirect_path
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
    connection = Connection.find_by_id connection_id
    EventDispatcher.emit(%w(user app_link_clicked),
      initiator: 'user',
      data: {
        connection_id: connection.id,
        connection_creator_mkey: connection.creator.mkey,
        connection_target_mkey: connection.target.mkey,
        platform: platform
      },
      raw_params: { user_agent: user_agent.raw }
    ) if connection
  end

  def send_warning(message)
    Rollbar.warning message, user_agent: user_agent.raw
  end
end
