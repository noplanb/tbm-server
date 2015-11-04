class HandleOutgoingVideo
  attr_reader :s3_event, :s3_metadata

  def initialize(s3_event_params)
    @s3_event = S3Event.new s3_event_params
    @errors   = {}
  end

  def do
    return false unless s3_event.valid?
    @s3_metadata = S3Metadata.create_by_event s3_event
    handle_outgoing_video if client_version_allowed?
    true
  rescue ActiveRecord::RecordNotFound => e
    @errors[e.class.name] = e.message
    false
  end

  def errors
    @errors.merge s3_event.errors.messages
  end

  def log_messages(status)
    debug_info = "s3 event: #{@s3_event.inspect}; s3 metadata: #{@s3_metadata.inspect}"
    case status
      when :success then WriteLog.info self, "s3 event was handled successfully at #{Time.now}; #{debug_info}"
      when :failure then WriteLog.info self, "errors occurred with handle s3 event at #{Time.now}; errors: #{errors.inspect}; #{debug_info}", rollbar: :error
    end
  end

  private

  def handle_outgoing_video
    update_kvstore_with_video_id
    send_notification_to_receiver
  end

  def update_kvstore_with_video_id
    Kvstore.add_id_key sender_user, receiver_user, s3_metadata.video_id
  end

  def send_notification_to_receiver
    params = { target_mkey: receiver_user.mkey, from_mkey: sender_user.mkey, sender_name: sender_user.name, video_id: s3_metadata.video_id }
    Notification::VideoReceived.new(receiver_push_user, Figaro.env.domain_name, sender_user).process(params, params[:from_mkey], params[:sender_name], params[:video_id])
  end

  def client_version_allowed?
    return true if s3_metadata.client_platform == 'android' && s3_metadata.client_version >= 112
    return true if s3_metadata.client_platform == 'ios'     && s3_metadata.client_version >= 38
    false
  end

  def sender_user
    @sender_user ||= User.find_by! mkey: s3_metadata.sender_mkey
  end

  def receiver_user
    @receiver_user ||= User.find_by! mkey: s3_metadata.receiver_mkey
  end

  def receiver_push_user
    @receiver_push_user ||= PushUser.find_by! mkey: s3_metadata.receiver_mkey
  end
end
