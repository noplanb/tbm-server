class LandingController < ApplicationController
  layout 'landing'

  def index
    render :invite
  end

  def invite
    platform = :unknown
    redirect_path = nil

    if android? && ios?
      platform = :mobile_device
      redirect_path = root_path
      Rollbar.warning('Both iOS and Android detected')
    elsif android?
      platform = :android
      redirect_path = android_store_url
    elsif ios?
      platform = :ios
      redirect_path = iphone_store_url
    elsif mobile_device?
      platform = :mobile_device
      redirect_path = root_path
      Rollbar.warning('Unsupported User Agent detected')
    end

    fire_app_link_clicked_event platform
    redirect_to redirect_path if redirect_path

    # todo: implement service like this
    # Landing::HandleAppLinkClickedEvent.new(request) { |path| redirect_to path }
  end

  def privacy
  end

  def ios_coming_soon
  end

  private

  def fire_app_link_clicked_event(platform)
    connection = Connection.find_by_id params[:id]
    EventDispatcher.emit(%w(user app_link_clicked),
      initiator: 'user',
      data: {
        connection_id: connection.id,
        connection_creator_mkey: connection.creator.mkey,
        connection_target_mkey: connection.target.mkey,
        platform: platform
      },
      raw_params: { user_agent: request.user_agent }
    ) if connection
  end
end
