class NotificationController < ApplicationController
  before_action :authenticate
  before_action :send_notification_enabled, only: [:send_video_received,
                                                   :send_video_status_update]
  before_action :find_target_push_user, only: [:send_video_received,
                                               :send_video_status_update]

  def set_push_token
    PushUser.create_or_update(push_user_params)
    logger.info("set_push_token: #{push_user_params}")
    render json: { status: '200' }
  end

  def send_video_received
    @push_user.send_notification(type: :alert,
                                      alert: "New message from #{params[:sender_name]}",
                                      payload: { type: 'video_received',
                                                 from_mkey: params[:from_mkey],
                                                 video_id: params[:video_id] })
    render json: { status: '200' }
  end

  def send_video_status_update
    @push_user.send_notification(type: :silent,
                                       payload: { type: 'video_status_update',
                                                  to_mkey: params[:to_mkey],
                                                  status: params[:status],
                                                  video_id: params[:video_id] })
    render json: { status: '200' }
  end

  # ====================
  # = LoadTest Methods =
  # ====================
  # mimic a send notification
  def load_test_send_notification
    # get push user
    pu = PushUser.find_by_mkey params[:mkey]
    # do an http request to google
    # uri = URI.parse("http://www.google.com/?#safe=off&q=eggsalad")
    uri = URI.parse('http://www.yahoo.com')
    resp = Net::HTTP.get_response(uri)
    logger.info "pu=#{pu} body_count=#{resp.body.length}"
    render text: 'ok'
  end

  private

  def find_target_push_user
    @push_user = params[:target_mkey] && PushUser.find_by_mkey(params[:target_mkey])
    if @push_user.nil?
      logger.info("No PushUser found for mkey: #{params[:target_mkey]}")
      render json: { status: '404' }
    end
  end

  def push_user_params
    params.permit(:mkey, :push_token, :device_platform, :device_build)
  end

  def send_notification_enabled
    # render json: {status:"failure"}
    true
  end
end
