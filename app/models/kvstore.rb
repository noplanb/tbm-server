class Kvstore < ActiveRecord::Base
  def self.create_or_update(params)
    if params[:key2].blank?
      kvs = where('key1 = ? and key2 is null', params[:key1])
    else
      kvs = where('key1 = ? and key2 = ?', params[:key1], params[:key2])
    end

    if !kvs.blank?
      kvs.first.update_attribute(:value, params[:value])
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
    params[:value] = { 'videoId' => video_id, status: status }.to_json
    Kvstore.create_or_update(params)
  end

  def self.video_filename(sender, receiver, video_id)
    connection = Connection.live_between(sender.id, receiver.id).first
    "#{sender.mkey}-#{receiver.mkey}-#{digest(connection.ckey + video_id)}"
  end
end
