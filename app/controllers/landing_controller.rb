class LandingController < ApplicationController
  layout 'landing'
  before_action :set_state

  def index
    render :invite
  end

  def invite
    if windows_phone?
      Rollbar.warning('Windows Phone detected')
      redirect_to root_path
    elsif android? && ios?
      Rollbar.warning('Both iOS and Android detected')
      redirect_to root_path
    elsif android?
      redirect_to android_store_url
    elsif ios?
      redirect_to iphone_store_url
    elsif mobile_device?
      Rollbar.warning('Unsupported User Agent detected')
      redirect_to root_path
    end
  end

  def privacy
  end

  def ios_coming_soon
  end

  private

  def set_state
    @inviter = params[:id] && User.where(mkey: params[:id]).first
  end
end
