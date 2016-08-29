class Kvstore::Decorators::Default < Zazo::Model::Decorator
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

  def value(raw: false)
    @value ||= JSON.parse(model.value)
    raw ? @value : value_with_emojis
  end

  def stripped_value
    value.except('videoId', 'messageId', 'type')
  end

  private

  def value_with_emojis
    body = @value['body'] && Emojimmy.token_to_emoji(@value['body'])
    @value.merge('body' => body)
  end
end
