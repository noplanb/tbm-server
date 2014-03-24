# Used temporarily when we forward notifications from a dev machine to our server to be sent
# from a static non changing ip.
class NotificationController < ApplicationController  
  
  def send
    GcmServer.send_notification(params[:id], params[:payload])
    render :text => "ok"
  end
  
end