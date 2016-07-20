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

  def type
    value['type'] || 'video'
  end

  def value
    JSON.parse(model.value)
  end

  def stripped_value
    value.except('videoId', 'messageId', 'type')
  end
end
