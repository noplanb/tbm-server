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

  def self.generate_key(sender, receiver, connection)
    "#{sender.mkey}-#{receiver.mkey}-#{connection.ckey}-VideoIdKVKey"
  end

  def self.add_remote_key(sender, receiver, video_id)
    connection = Connection.live_between(sender.id, receiver.id).first
    fail 'no live connections found' if connection.nil?
    params = {}
    params[:key1] = generate_key(sender, receiver, connection)
    params[:key2] = video_id
    params[:value] = { 'videoId' => video_id }.to_json
    Kvstore.create_or_update(params)
  end

  def self.video_filename(sender, receiver, video_id)
    connection = Connection.live_between(sender.id, receiver.id).first
    "#{sender.mkey}-#{receiver.mkey}-#{Digest::MD5.new.update(connection.ckey + video_id).hexdigest}"
  end
end
