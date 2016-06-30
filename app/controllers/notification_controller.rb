class NotificationController < ApplicationController
  before_action :authenticate
  before_action :find_target_push_user, only: [:send_video_received, :send_video_status_update]

  def set_push_token
    PushUser.create_or_update(push_user_params)
    logger.info("set_push_token: #{push_user_params}")
    render json: { status: '200' }
  end

  def send_video_received
    instance = Notification::SendMessage.new(@push_user, request.host, current_user)
    instance.process(params, params[:from_mkey], params[:sender_name], params[:video_id])
    render json: { status: '200' }
  end

  def send_video_status_update
    instance = Notification::SendMessageStatus.new(@push_user, request.host)
    instance.process(params)
    render json: { status: '200' }
  end

  private

  def push_user_params
    params.permit(:mkey, :push_token, :device_platform, :device_build)
  end

  def find_target_push_user
    @push_user = params[:target_mkey] && PushUser.find_by_mkey(params[:target_mkey])
    if @push_user.nil?
      message = "No PushUser found for mkey: #{params[:target_mkey]}"
      logger.info(message)
      render json: { status: '404', title: 'Not found', message: message }, status: :not_found
    end
  end
end
