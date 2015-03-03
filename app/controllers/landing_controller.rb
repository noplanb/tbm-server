class LandingController < ApplicationController

  before_action :set_state

  layout "landing"

  def index
    render template: "landing/invite"
  end

  def invite
    render template: "landing/invite"
  end

  private

  def set_state
    @store_url = store_url

    @connection = params[:id] && Connection.where(id: params[:id]).first
    if (@connection)
      @inviter = @connection.creator
      @invitee = @connection.target
    end
  end

end
