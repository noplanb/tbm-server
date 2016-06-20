class Kvstore < ActiveRecord::Base
  SUFFIXES_FOR_EVENTS = %w(VideoIdKVKey VideoStatusKVKey).freeze
  after_save :trigger_event

  def self.create_or_update(params)
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

  def self.generate_key(suffix, sender, receiver, connection)
    sender_mkey = sender.is_a?(String) ? sender : sender.mkey
    receiver_mkey = receiver.is_a?(String) ? receiver : receiver.mkey
    connection_ckey = connection.is_a?(String) ? connection : connection.ckey
    [sender_mkey,
     receiver_mkey,
     digest(sender_mkey + receiver_mkey + connection_ckey),
     suffix].join('-')
  end

  def self.generate_id_key(sender, receiver, connection)
    generate_key 'VideoIdKVKey', sender, receiver, connection
  end

  def self.generate_status_key(sender, receiver, connection)
    generate_key 'VideoStatusKVKey', sender, receiver, connection
  end

  def self.generate_welcomed_friends_key(user)
    user_mkey = user.is_a?(String) ? user : user.mkey
    "#{user_mkey}-WelcomedFriends"
  end

  def self.add_id_key(sender, receiver, video_id)
    connection = Connection.live_between(sender.id, receiver.id).first
    fail 'no live connections found' if connection.nil?
    params = {}
    params[:key1] = generate_id_key(sender, receiver, connection)
    params[:key2] = video_id
    params[:value] = { 'videoId' => video_id }.to_json
    Kvstore.create_or_update(params)
  end

  def self.add_message_id_key(type, sender, receiver, message_id, rest = {})
    connection = Connection.live_between(sender.id, receiver.id).first
    fail 'no live connections found' if connection.nil?
    params = {
      key1: generate_id_key(sender, receiver, connection),
      key2: message_id,
      value: { 'type' => type, 'messageId' => message_id }.merge(rest).to_json
    }
    Kvstore.create_or_update(params)
  end

  def self.add_status_key(sender, receiver, video_id, status)
    connection = Connection.live_between(sender.id, receiver.id).first
    fail 'no live connections found' if connection.nil?
    params = {}
    params[:key1] = generate_status_key(sender, receiver, connection)
    params[:value] = { 'videoId' => video_id, 'status' => status }.to_json
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
    TriggerEvent.new(self).call
  end
end
