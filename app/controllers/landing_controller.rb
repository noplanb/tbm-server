class LandingController < ApplicationController
  include LandingHelper

  layout 'landing'

  def index
    render :invite
  end

  def invite
    Landing::HandleAppLinkClickedEvent.new(request.user_agent, params[:id]).do { |path| redirect_to path }
  end

  def privacy
  end
end
