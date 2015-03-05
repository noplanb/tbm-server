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
    @inviter = params[:id] && User.where(mkey: params[:id]).first
  end

end
