class Kvstore < ActiveRecord::Base
  after_save :trigger_event

  serialize :value, JSON

  def self.create_or_update(params)
    params[:value] = JSON.parse(params[:value]) if params[:value].is_a?(String)
    if params[:key2].blank?
      kvs = where('key1 = ? and key2 is null', params[:key1])
    else
      kvs = where('key1 = ? and key2 = ?', params[:key1], params[:key2])
    end

    if kvs.present?
      kvs.first.update_attribute(:value, params[:value])
      kvs.first
    else
      create(key1: params[:key1], key2: params[:key2], value: params[:value])
    end
  end

  def self.digest(string)
    Digest::MD5.new.update(string).hexdigest
  end

  def self.generate_id_key(sender, receiver, connection)
    sender_mkey = sender.is_a?(String) ? sender : sender.mkey
    receiver_mkey = receiver.is_a?(String) ? receiver : receiver.mkey
    connection_ckey = connection.is_a?(String) ? connection : connection.ckey
    "#{sender_mkey}-#{receiver_mkey}-#{digest(sender_mkey + receiver_mkey + connection_ckey)}-VideoIdKVKey"
  end

  def self.generate_status_key(sender, receiver, connection)
    sender_mkey = sender.is_a?(String) ? sender : sender.mkey
    receiver_mkey = receiver.is_a?(String) ? receiver : receiver.mkey
    connection_ckey = connection.is_a?(String) ? connection : connection.ckey
    "#{sender_mkey}-#{receiver_mkey}-#{digest(sender_mkey + receiver_mkey + connection_ckey)}-VideoStatusKVKey"
  end

  def self.add_id_key(sender, receiver, video_id)
    connection = Connection.live_between(sender.id, receiver.id).first
    fail 'no live connections found' if connection.nil?
    params = {}
    params[:key1] = generate_id_key(sender, receiver, connection)
    params[:key2] = video_id
    params[:value] = { 'videoId' => video_id }
    Kvstore.create_or_update(params)
  end

  def self.add_status_key(sender, receiver, video_id, status)
    connection = Connection.live_between(sender.id, receiver.id).first
    fail 'no live connections found' if connection.nil?
    params = {}
    params[:key1] = generate_status_key(sender, receiver, connection)
    params[:value] = { 'videoId' => video_id, 'status' => status }
    Kvstore.create_or_update(params)
  end

  def self.video_filename(sender, receiver, video_id)
    sender = User.find_by!(mkey: sender) if sender.is_a?(String)
    receiver = User.find_by!(mkey: receiver) if receiver.is_a?(String)
    connection = Connection.live_between(sender.id, receiver.id).first
    fail "No connection found between #{sender.name} and #{receiver.name}" if connection.nil?
    "#{sender.mkey}-#{receiver.mkey}-#{digest(connection.ckey + video_id)}"
  end

  private

  def trigger_event
    return false if key1.blank? && value.blank?
    sender_id, receiver_id, _hash, _type = key1.split('-')
    status = value.fetch('status', 'received')
    video_id = value['videoId']
    video_filename = self.class.video_filename(sender_id, receiver_id, video_id)
    name = ['video', self.class.name.underscore, status]
    event = {
      initiator: 'user',
      initiator_id: sender_id,
      target: 'video',
      target_id: video_filename,
      data: {
        sender_id: sender_id,
        receiver_id: receiver_id,
        video_filename: video_filename,
        video_id: video_id
      },
      raw_params: attributes.slice('key1', 'key2', 'value') }
    EventDispatcher.emit(name, event)
  end
end
