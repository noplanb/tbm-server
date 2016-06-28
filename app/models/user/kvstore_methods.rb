module User::KvstoreMethods
  def received_videos
    data = reduce_by_mkeys(kv_keys_for_received_messages) do |key1|
      key1.split('-').first
    end
    data.map do |mkey, values|
      video_ids = values.map { |v| JSON.parse(v)['videoId'] }
      { mkey: mkey, video_ids: video_ids }
    end
  end

  def video_status
    data = reduce_by_mkeys(kv_keys_for_message_status) do |key1|
      key1.split('-').second
    end
    data.map do |mkey, values|
      value = values.last || { 'videoId' => '', 'status' => '' }.to_json
      decoded = JSON.parse(value)
      { mkey: mkey, video_id: decoded['videoId'], status: decoded['status'] }
    end
  end

  def received_messages
    data = reduce_by_mkeys(kv_keys_for_received_messages) { |key1| key1.split('-').first }
    data.map do |mkey, values|
      messages = values.map do |v|
        value = JSON.parse(v)
        if value['type']
          value
        else
          { 'type' => 'video', 'messageId' => value['videoId'] }
        end
      end
      { mkey: mkey, messages: messages }
    end
  end

  def received_texts
    filter_received_messages('text')
  end

  def messages_statuses
    data = reduce_by_mkeys(kv_keys_for_message_status) { |key1| key1.split('-').second }
    data.map do |mkey, values|
      value = values.last
      value &&= JSON.parse(value)
      message = value && {
        type: value['type'] || 'video',
        message_id: value['messageId'] || value['videoId'],
        status: value['status'] }
      { mkey: mkey, message: message }
    end
  end

  private

  def kv_keys_for_received_messages
    live_connections.map do |connection|
      Kvstore.generate_id_key(connected_user_mkey(connection), self, connection)
    end
  end

  def kv_keys_for_message_status
    live_connections.map do |connection|
      Kvstore.generate_status_key(self, connected_user_mkey(connection), connection)
    end
  end

  def reduce_by_mkeys(kv_keys)
    data = find_user_kv_records(kv_keys)
    hash = Hash[connected_users_cache.map { |_, mkey| [mkey, []] }]
    data.each_with_object(hash) do |(item, _), result|
      key1, value = item
      mkey = yield(key1) # block to extract +mkey+ from +key1+ value
      result[mkey] ||= []
      result[mkey] << value
    end
  end

  def find_user_kv_records(kv_keys)
    Kvstore.where(key1: kv_keys).group(:key1, :value).count
  end

  def filter_received_messages(type)
    received_messages.each do |row|
      row[:messages].select! { |m| m['type'] == type }
    end
  end
end
