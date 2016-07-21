class Kvstore::Wrapper
  attr_reader :model

  def initialize(model)
    @model = model
  end

  def key1
    model.key1
  end

  def key2
    model.key2
  end

  def message_id
    key2 || value['messageId'] || value['videoId']
  end

  def type
    value['type'] || 'video'
  end

  def type?(_type)
    type == _type.to_s
  end

  def status
    value['status']
  end

  def value
    JSON.parse(model.value)
  end

  def stripped_value
    value.except('videoId', 'messageId', 'type')
  end
end
