class NotificationService
  attr_reader :push_user, :request, :current_user

  def initialize(push_user, request, current_user = nil)
    @push_user = push_user
    @request = request
    @current_user = current_user
  end

  def notify_video_received(params, sender_mkey, video_id)
    video_filename = Kvstore.video_filename(sender_mkey,
                                            push_user.mkey,
                                            video_id)

    message = { initiator: 'admin', initiator_id: nil }
    if current_user.present?
      message.update(initiator: 'user', initiator_id: current_user.mkey)
    end
    EventDispatcher.emit(%w(video notification received),
                         message.merge(
                           target: 'video',
                           target_id: video_filename,
                           data: {
                             sender_id: sender_mkey,
                             sender_platform: User.find_by_mkey(sender_mkey).try(:device_platform),
                             receiver_id: push_user.mkey,
                             receiver_platform: push_user.try(:device_platform),
                             video_filename: video_filename,
                             video_id: video_id
                           },
                           raw_params: params.except(:controller, :action)))
  end

  def send_video_received_notification(params, sender_mkey, sender_name, video_id)
    notify_video_received(params, sender_mkey, video_id)
    push_user.send_notification(type: :alert,
                                alert: "New message from #{sender_name}",
                                badge: 1,
                                payload: { type: 'video_received',
                                           from_mkey: sender_mkey,
                                           video_id: video_id,
                                           host: request.host })
  end

  def notify_video_status_updated(params)
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

  def send_video_status_updated_notification(params)
    notify_video_status_updated(params)
    push_user.send_notification(type: :silent,
                                payload: { type: 'video_status_update',
                                           to_mkey: params[:to_mkey],
                                           status: params[:status],
                                           video_id: params[:video_id],
                                           host: request.host })
  end
end
