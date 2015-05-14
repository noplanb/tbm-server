class LandingController < ApplicationController
  include LandingHelper # FIXME: should be included automatically

  layout 'landing'
  before_action :set_state

  def index
    render :invite
  end

  def invite
    if android? && ios?
      Rollbar.warning('Both iOS and Android detected')
      redirect_to root_path
    elsif windows_phone?
      Rollbar.warning('Windows Phone detected')
    elsif android?
      redirect_to android_store_url
    elsif ios?
      redirect_to iphone_store_url
    else
      Rollbar.warning('Unsupported User Agent detected') if mobile_device?
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
