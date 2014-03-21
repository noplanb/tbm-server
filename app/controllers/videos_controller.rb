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
      Logger.error 
      return
    end
    
    SEND_NOTIFICATIONS_LOCALLY ? send_notification_locally(video) : forward_notification_to_tbm_server(video)
  end
  
  def get
    v = Video.where("receiver_id = ? and user_id = ?", params[:receiver_id], params[:user_id]).order(id: :desc).limit(1).first
    logger.info("Found video_id = #{v.id}")
    send_file( "public" + v.file.url, type: "video/mp4")
  end
  
  def send_notification_locally(video)
    logger.info "send_notification_locally"
    p = gcm_params video
    send_notification(p[:id], p[:payload])
  end
  
  def forward_notification_to_tbm_server(video)
    logger.info "forward_notification_to_tbm_server"
    uri = URI("http://localhost:3000/notification/send")
    res = Net::HTTP.post_form(uri, gcm_params(video))
    logger.info res.body
  end
  
  def gcm_params(video)
    { id: video.receiver.push_token, payload: {from_id: video.user.id.to_s} }
  end
  

end
