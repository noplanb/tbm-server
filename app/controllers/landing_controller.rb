class LandingController < ApplicationController
  
  def invite
    conn = Connection.find params[:id]
    @inviter = conn.creator
    @invitee = conn.target
    @store_link = store_link
    render template: "landing/invite"
  end
  
end
