class LandingController < ApplicationController
  layout 'landing'
  before_action :set_state

  def index
    render :invite
  end

  def invite
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
