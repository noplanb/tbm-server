class Notification::VideoStatusUpdated
  attr_reader :push_user, :host

  def initialize(push_user, host)
    @push_user = push_user
    @host = host
  end

  def process(params)
    trigger_event(params)
    push_user.send_notification(type: :silent,
                                payload: { type: 'video_status_update',
                                           to_mkey: params[:to_mkey],
                                           status: params[:status],
                                           video_id: params[:video_id],
                                           host: host })
  end

  protected

  def trigger_event(params)
    video_filename = Kvstore.video_filename(params[:target_mkey],
                                            params[:to_mkey],
                                            params[:video_id])
    EventDispatcher.emit(['video', 'notification', params[:status]],
                         initiator: 'user',
                         initiator_id: push_user.mkey,
                         target: 'video',
                         target_id: video_filename,
                         data: {
                           sender_id: params[:target_mkey],
                           sender_platform: User.find_by_mkey(params[:target_mkey]).try(:device_platform),
                           receiver_id: params[:to_mkey],
                           receiver_platform: User.find_by_mkey(params[:to_mkey]).try(:device_platform),
                           video_filename: video_filename,
                           video_id: params[:video_id]
                         },
                         raw_params: params.except(:controller, :action))
  end
end
