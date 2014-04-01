class VideosController < ApplicationController  
  skip_before_filter :verify_authenticity_token
  # protect_from_forgery :except => [:create]
  
  include GcmServer
  
  SEND_NOTIFICATIONS_LOCALLY = true
  
  # Really should only be used for testing
  def new
    @video = Video.new
  end

  # POST
  def create
    video = Video.create!(user_id: params[:user_id], file: params[:file], receiver_id: params[:receiver_id])
    logger.info("Uploaded file")
    render :text => "ok"
    
    if !video.receiver || video.receiver.push_token.blank?
      logger.error "Receiver #{video.receiver.first_name}[#{video.receiver.id}] did not have a push_token" 
      return
    end
    
    gcm_params = { id: video.receiver.push_token, payload: {type: "video_received", from_id: video.user.id.to_s} }
    send_notification_per_config(gcm_params)
  end
  
  def get
    v = Video.where("receiver_id = ? and user_id = ?", params[:receiver_id], params[:user_id]).order(id: :desc).limit(1).first
    logger.info("Found video_id = #{v.id}")
    send_file( "public" + v.file.url, type: "video/mp4")
    sender = User.find(params[:user_id])
    gcm_params = {id: sender.push_token, payload: {type: "video_status_update", to_id: params[:receiver_id], status: "downloaded"}}
    send_notification_per_config(gcm_params)
  end
  
  def update_viewed()
    render :text => "ok"
    sender = User.find(params[:from_id])
    gcm_params = {id: sender.push_token, payload: {type: "video_status_update", to_id: params[:to_id], status: "viewed"}}
    send_notification_per_config(gcm_params)
  end
  
  def send_notification_per_config(gcm_params)
    SEND_NOTIFICATIONS_LOCALLY ? send_notification_locally(gcm_params) : forward_notification_to_tbm_server(gcm_params)
  end
  
  def send_notification_locally(gcm_params)
    logger.info "send_notification_locally"
    send_notification(gcm_params[:id], gcm_params[:payload])
  end
  
  def forward_notification_to_tbm_server(gcm_params)
    logger.info "forward_notification_to_tbm_server"
    uri = URI("http://localhost:3000/notification/send")
    res = Net::HTTP.post_form(uri, gcm_params)
    logger.info res.body
  end
  
end
