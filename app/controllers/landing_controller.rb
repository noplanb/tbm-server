class LandingController < ApplicationController
  include LandingHelper

  layout 'landing'
  before_action :set_inviter, only: [:invite, :legacy]

  def index
    render :invite
  end

  def invite
    Landing::HandleAppLinkClickedEvent.new(request.user_agent, connection: @connection).do do |path|
      path && redirect_to(path)
    end
  end

  def legacy
    Landing::HandleAppLinkClickedEvent.new(request.user_agent, inviter: @inviter).do do |path|
      path ? redirect_to(path) : render(:invite)
    end
  end

  def privacy
  end

  private

  def set_inviter
    case params[:action]
      when 'invite'
        @connection = Connection.find_by_id params[:id]
        @invitee, @inviter = @connection.target, @connection.creator if @connection
      when 'legacy'
        @inviter = User.find_by_id params[:id]
    end
  end
end
