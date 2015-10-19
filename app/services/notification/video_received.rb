class Notification::VideoReceived
  attr_reader :push_user, :host, :current_user

  def initialize(push_user, host, current_user)
    @push_user = push_user
    @current_user = current_user
    @host = host
  end

  def message
    message = { initiator: 'admin', initiator_id: nil }
    message.update(initiator: 'user', initiator_id: current_user.mkey) if current_user.present?
    message
  end

  def process(params, sender_mkey, sender_name, video_id)
    trigger_event(params, sender_mkey, video_id)
    push_user.send_notification(type: :alert,
                                alert: "New message from #{sender_name}",
                                badge: 1,
                                payload: { type: 'video_received',
                                           from_mkey: sender_mkey,
                                           video_id: video_id,
                                           host: host })

  end

  protected

  def trigger_event(params, sender_mkey, video_id)
    video_filename = Kvstore.video_filename(sender_mkey,
                                            push_user.mkey,
                                            video_id)
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
end
