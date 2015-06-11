class Kvstore < ActiveRecord::Base
  after_save :trigger_event

  scope :video_id_kv_keys, -> { where("`#{table_name}`.`key1` LIKE ?", '%VideoIdKVKey') }
  scope :video_status_kv_keys, -> { where("`#{table_name}`.`key1` LIKE ?", '%VideoStatusKVKey') }
  scope :with_sender, ->(sender) { where("SPLIT_STR(`#{table_name}`.`key1`, ?, ?) = ?", '-', 1, sender) }
  scope :with_receiver, ->(receiver) { where("SPLIT_STR(`#{table_name}`.`key1`, ?, ?) = ?", '-', 2, receiver) }

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

  def self.generate_id_key(sender, receiver, connection)
    "#{sender.mkey}-#{receiver.mkey}-#{connection.ckey}-VideoIdKVKey"
  end

  def self.generate_status_key(sender, receiver, connection)
    "#{sender.mkey}-#{receiver.mkey}-#{digest(sender.mkey + receiver.mkey + connection.ckey)}-VideoStatusKVKey"
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

  def self.received_videos(user)
    data = reduce_by_receiver(:video_id_kv_keys, user, :key2)
    data.map do |friend_mkey, video_ids|
      { mkey: friend_mkey, video_ids: video_ids }
    end
  end

  def self.video_status(user)
    data = reduce_by_receiver(:video_status_kv_keys, user, :value)
    data.map do |friend_mkey, values|
      value = values.last || { 'videoId' => nil, 'status' => nil }.to_json
      decoded = JSON.parse(value)
      { mkey: friend_mkey, video_id: decoded['videoId'], status: decoded['status'] }
    end
  end

  private

  def trigger_event
    return false if key1.blank? && value.blank?
    sender_id, receiver_id, _hash, _type = key1.split('-')
    parsed_value = JSON.parse(value)
    status = parsed_value.fetch('status', 'received')
    video_id = parsed_value['videoId']
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

  def self.friends_hash(user)
    Hash[user.connected_users.pluck(:mkey).map { |mkey| [mkey, []] }]
  end

  def self.receiver_mkey_sql
    "SPLIT_STR(`#{table_name}`.`key1`, '-', 2)"
  end

  def self.reduce_by_receiver(initial_scope, user, other_column = :key2)
    data = send(initial_scope).with_sender(user.mkey)
           .select(receiver_mkey_sql, other_column)
           .group(receiver_mkey_sql).group(other_column).order(:updated_at).count(other_column)
    data.each_with_object(friends_hash(user)) do |(key, _value), result|
       friend_mkey, column_value = key
       result[friend_mkey] ||= []
       result[friend_mkey] << column_value
    end
  end
end
