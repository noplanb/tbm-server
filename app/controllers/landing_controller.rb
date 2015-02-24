class LandingController < ApplicationController
  
  layout "landing"
  
  def invite
    conn = Connection.find params[:id]
    @inviter = conn.creator
    @invitee = conn.target
    @store_url = store_url
    render template: "landing/invite"
  end
  
end
