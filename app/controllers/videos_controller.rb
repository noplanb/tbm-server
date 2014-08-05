require "no_plan_b/core_extensions/ruby/string"

class VideosController < ApplicationController  
  skip_before_filter :verify_authenticity_token
    
  def create
    video = Video.create_or_update(filename: params[:filename], file: params[:file])
    logger.info("Uploaded file: #{params[:filename]}")
    render :json => {"status" => 200}
  end
  
  def get
    v = params[:filename] && Video.find_by_filename(params[:filename])
    v || not_found
        
    logger.info("Found video = #{v.filename}")
    send_file( "public" + v.file.url, type: "video/mp4")
  end
  
  def delete
    v = params[:filename] && Video.find_by_filename(params[:filename])
    if v
      v.destroy
    else
      logger.error("Delete: no video found with filename #{v.filename}") if !v
    end
    render :json => {"status" => 200}
  end
  
  private
  
  def not_found
    # This should send the proper 404 status to the device.
    raise ActionController::RoutingError.new('Not Found')
  end
  
  
end
