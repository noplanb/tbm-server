class VideosController < ApplicationController  
  skip_before_filter :verify_authenticity_token
  # protect_from_forgery :except => [:create]
  # changed a line

  def new
    render text: "NOT IMPLEMENTED"
  end

  # Really should only be used for testing
  def new
    @video = Video.new
  end

  # POST
  def create
    video = Video.create!(user_id: params[:user_id], file: params[:file], receiver_id: params[:receiver_id])
    logger.info("Uploaded file")
    render :text => "ok"
    response = GcmHandler.send_for_video(video)
    logger.info response.inspect
  end
  
  def get
    v = Video.where("receiver_id = ? and user_id = ?", params[:receiver_id], params[:user_id]).order(id: :desc).limit(1).first
    logger.info("Found video_id = #{v.id}")
    send_file( "public" + v.file.url, type: "video/mp4")
  end

end
