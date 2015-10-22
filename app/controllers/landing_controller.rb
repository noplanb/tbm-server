class LandingController < ApplicationController
  include LandingHelper

  layout 'landing'
  before_action :set_inviter, only: :invite

  def index
    render :invite
  end

  def invite
    Landing::HandleAppLinkClickedEvent.new(request.user_agent, params[:id]).do { |path| redirect_to path }
  end

  def privacy
  end

  private

  def set_inviter
    connection = Connection.find_by_id params[:id]
    @inviter = connection.creator if connection
  end
end
