class NotificationController < ApplicationController  
  skip_before_filter :verify_authenticity_token
  
  def set_push_token
    PushUser.create_or_update(push_user_params)
    render :text => "ok"
  end
  
  def send_video_received
    target_push_user = get_target_push_user
    render :text => "fail" and return if !target_push_user
    
    gpn = GenericPushNotification.new({
      :platform  => target_push_user.device_platform, 
      :token => target_push_user.push_token, 
      :type => :alert, 
      :payload => {type: "video_received", 
                   from_mkey: params[:from_mkey], 
                   video_id: params[:video_id]},
      :alert => "New message from #{params[:sender_name]}", 
      :sound => "default", 
      :content_available  => true
    })
    gpn.send
    
    render :text => "ok"
  end
  
  def send_video_status_update
    target_push_user = get_target_push_user
    render :text => "fail" and return if !target_push_user
    
    gpn = GenericPushNotification.new({
      :platform  => target_push_user.device_platform, 
      :token => target_push_user.push_token, 
      :type => :silent, 
      :payload => {type: "video_status_update", 
                   to_mkey: params[:to_mkey], 
                   status: params[:status], 
                   video_id: params[:video_id]},
      :content_available  => true
    })
    gpn.send
    
    render :text => "ok"
  end
  
  private 
  
  def get_target_push_user
    r = params[:target_mkey] && PushUser.find_by_mkey(params[:target_mkey]) 
    logger.info("No PushUser found for mkey: #{params[:target_mkey]}") if r.nil?
    r
  end
  
  def push_user_params
    params.permit(:mkey, :push_token, :device_platform)
  end
  
end