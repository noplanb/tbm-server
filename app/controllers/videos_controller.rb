require "no_plan_b/core_extensions/ruby/string"

class VideosController < ApplicationController  
  skip_before_filter :verify_authenticity_token
  # protect_from_forgery :except => [:create]
  
  SEND_NOTIFICATIONS_LOCALLY = true
  
  # Really should only be used for testing
  def new
    @video = Video.new
  end

  # POST
  def create
    if params[:video_id].blank?
      video = Video.create!(user_id: params[:user_id], 
                            file: params[:file], 
                            receiver_id: params[:receiver_id],
                            status: :uploaded)
    else
      video = Video.create_by_decoding_video_id!(video_id: params[:video_id],
                                                 file: params[:file],
                                                 status: :uploaded)
    end
    
    logger.info("Uploaded file")
    render :json => {"status" => 200}
    
    if !params[:last_video_id].blank?
      last_video = Video.find_by_video_id(params[:last_video_id])
      if last_video
        last_video.destroy 
        logger.info "Destroyed [#{params[:last_video_id]}]"
      end
    else
      Video.destroy_all_but_last_with_user_id_and_receiver_id(video.user_id, video.receiver_id)
    end
    
    if !video.receiver || video.receiver.push_token.blank?
      logger.error "Receiver #{video.receiver.first_name}[#{video.receiver.id}] did not have a push_token" 
      return
    end
        
    gpn = GenericPushNotification.new({
      :platform  => video.receiver.device_platform, 
      :token => video.receiver.push_token, 
      :type => :alert, 
      :payload => {type: "video_received", 
                   from_id: video.user.id.to_s, 
                   video_id: video.video_id,
                   videosRequiringDownload: [video.video_id]},
      :alert => "New message from #{video.user.first_name.capitalize_words}", 
      :sound => "default", 
      :content_available  => true
    })
    gpn.send
    # gcm_params = { id: video.receiver.push_token, payload: {type: "video_received", from_id: video.user.id.to_s} }
    #send_notification_per_config(gcm_params)
  end
  
  def get
    if params[:video_id].blank?
      v = Video.find_last_with_user_id_and_receiver_id(params[:user_id], params[:receiver_id])
    else
      v = Video.find_by_video_id params[:video_id]
    end
    v || not_found
    
    v.update_attribute(:status, :downloaded)
    
    logger.info("Found video_id = #{v.id}")
    send_file( "public" + v.file.url, type: "video/mp4")
    
    gpn = GenericPushNotification.new({
      :platform  => v.user.device_platform, 
      :token => v.user.push_token, 
      :type => :silent, 
      :payload => {type: "video_status_update", 
                   to_id: v.receiver_id, 
                   status: "downloaded", 
                   video_id: v.video_id,
                   videoStatusUpdates: [{videoId: v.video_id, status: "downloaded"}]},
      :content_available  => true
    })
    gpn.send
    # gcm_params = {id: sender.push_token, payload: {type: "video_status_update", to_id: params[:receiver_id], status: "downloaded"}}
    # send_notification_per_config(gcm_params)
  end
  
  def test_get
    v = Video.last
    send_file("public" + v.file.url, type:"video/mov")
  end
  
  def update_viewed()
    render :json => {"status" => 200}
    
    if params[:video_id].blank?
      v = Video.find_last_with_user_id_and_receiver_id(params[:from_id], params[:to_id])      
    else
      v = Video.find_by_video_id(params[:video_id]) 
    end
    v || not_found
    
    v.update_attribute(:status, :viewed)
    
    gpn = GenericPushNotification.new({
      :platform  => v.user.device_platform, 
      :token => v.user.push_token, 
      :type => :silent, 
      :payload => {type: "video_status_update", 
                   to_id: v.receiver_id, 
                   status: "viewed", 
                   video_id: v.video_id, 
                   videoStatusUpdates: [{videoId: v.video_id, status: "viewed"}], 
                   },
      :content_available  => true
    })
    gpn.send
    # gcm_params = {id: sender.push_token, payload: {type: "video_status_update", to_id: params[:to_id], status: "viewed"}}
    # send_notification_per_config(gcm_params)
  end
  
  def not_found
    # This should send the proper 404 status to the device.
    raise ActionController::RoutingError.new('Not Found')
  end
  
  
  # def send_notification_per_config(gcm_params)
  #   SEND_NOTIFICATIONS_LOCALLY ? send_notification_locally(gcm_params) : forward_notification_to_tbm_server(gcm_params)
  # end
  # 
  # def send_notification_locally(gcm_params)
  #   logger.info "send_notification_locally"
  #   send_notification(gcm_params[:id], gcm_params[:payload])
  # end
  # 
  # def forward_notification_to_tbm_server(gcm_params)
  #   logger.info "forward_notification_to_tbm_server"
  #   uri = URI("http://localhost:3000/notification/send")
  #   res = Net::HTTP.post_form(uri, gcm_params)
  #   logger.info res.body
  # end
  
end
