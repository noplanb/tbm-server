class Kvstore::GetMessages
  LEGACY_METHODS = %i(received_videos video_status)

  attr_reader :user

  def initialize(user:)
    @user = user
  end

  # filtering is not implemented yet
  def call(filter: nil)
    data_messages = reduce_by_mkeys(kv_keys_for_received_messages) { |key1| key1.split('-').first }
    data_statuses = reduce_by_mkeys(kv_keys_for_message_status) { |key1| key1.split('-').second }
    mkeys = (data_messages.keys + data_statuses.keys).uniq
    mkeys.map do |mkey|
      { mkey: mkey,
        messages: data_messages[mkey].map { |v| build_message_by_value(v) },
        statuses: [build_status_by_value(data_statuses[mkey].last)].compact }
    end
  end

  def legacy(method)
    raise ArgumentError, 'method is not allowed' unless LEGACY_METHODS.include?(method)
    send(method)
  end

  private

  #
  # legacy methods
  #

  def received_videos
    data = reduce_by_mkeys(kv_keys_for_received_messages) { |key1| key1.split('-').first }
    data.map do |mkey, values|
      video_ids = values.map do |v|
        value = JSON.parse(v)
        value['type'] == 'video' ? value['messageId'] : value['videoId']
      end.compact
      { mkey: mkey, video_ids: video_ids }
    end
  end

  def video_status
    data = reduce_by_mkeys(kv_keys_for_message_status) { |key1| key1.split('-').second }
    data.map do |mkey, values|
      value = values.last
      value &&= JSON.parse(value)
      video_id = status = ''
      if value
        video_id, status = [value['videoId'], value['status']] unless value['type']
        video_id, status = [value['messageId'], value['status']] if value['type'] == 'video'
      end
      { mkey: mkey, video_id: video_id, status: status }
    end
  end

  #
  # helper methods
  #

  def kv_keys_for_received_messages
    user.live_connections.map do |connection|
      Kvstore.generate_id_key(user.send(:connected_user_mkey, connection), user, connection)
    end
  end

  def kv_keys_for_message_status
    user.live_connections.map do |connection|
      Kvstore.generate_status_key(user, user.send(:connected_user_mkey, connection), connection)
    end
  end

  def reduce_by_mkeys(kv_keys)
    data = find_user_kv_records(kv_keys)
    hash = Hash[user.send(:connected_users_cache).map { |_, mkey| [mkey, []] }]
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

  def build_message_by_value(value)
    value = JSON.parse(value)
    if value['type']
      rest = value.except('type', 'messageId').symbolize_keys
      { type: value['type'], message_id: value['messageId'] }.merge(rest)
    else
      { type: 'video', message_id: value['videoId'] }
    end
  end

  def build_status_by_value(value)
    value &&= JSON.parse(value)
    { type: value['type'] || 'video',
      message_id: value['messageId'] || value['videoId'],
      status: value['status'] } if value
  end
end
