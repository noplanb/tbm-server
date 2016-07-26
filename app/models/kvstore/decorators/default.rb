class Kvstore::Decorators::Default < Zazo::Tools::Model::Decorator
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
    value['status'] || 'received'
  end

  def value
    JSON.parse(model.value)
  end

  def stripped_value
    value.except('videoId', 'messageId', 'type')
  end
end
