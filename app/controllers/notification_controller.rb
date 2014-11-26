class NotificationController < ApplicationController  
  skip_before_filter :verify_authenticity_token
  
  def set_push_token
    PushUser.create_or_update(push_user_params)
    logger.info("set_push_token: #{push_user_params}")
    render :json => {status: "200"}
  end
  
  def send_video_received
    target_push_user = get_target_push_user
    render :json => {status: "404"} and return if !target_push_user
    
    gpn = GenericPushNotification.new({
      :platform  => target_push_user.device_platform, 
      :build => target_push_user.device_build,
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
    
    render :json => {status: "200"}
  end
  
  def send_video_status_update
    target_push_user = get_target_push_user
    render :json => {status: "404"} and return if !target_push_user
    
    gpn = GenericPushNotification.new({
      :platform  => target_push_user.device_platform, 
      :build => target_push_user.device_build,
      :token => target_push_user.push_token, 
      :type => :silent, 
      :payload => {type: "video_status_update", 
                   to_mkey: params[:to_mkey], 
                   status: params[:status], 
                   video_id: params[:video_id]},
      :content_available  => true
    })
    gpn.send
    
    render :json => {status: "200"}
  end
  
  # ====================
  # = LoadTest Methods =
  # ====================
  
  def load_test_populate
    render text:"Usage load_test_populate?start=n&end=m" and return unless params[:start] && params[:end]
    PushUser.load_test_populate(params[:start].to_i, params[:end].to_i)
    render text:"push_user count = #{PushUser.count}"
  end
  
  private 
  
  def get_target_push_user
    r = params[:target_mkey] && PushUser.find_by_mkey(params[:target_mkey]) 
    logger.info("No PushUser found for mkey: #{params[:target_mkey]}") if r.nil?
    r
  end
  
  def push_user_params
    params.permit(:mkey, :push_token, :device_platform, :device_build)
  end
  
end