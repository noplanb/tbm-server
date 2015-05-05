class EventDispatcher
  @send_message_enabled = true

  def self.queue_url
    Figaro.env.sqs_queue_url
  end

  def self.sqs_client
    @sqs_client ||= Aws::SQS::Client.new
  end

  def self.enable_send_message!
    @send_message_enabled = true
  end

  def self.disable_send_message!
    @send_message_enabled = false
  end

  def self.send_message_enabled?
    @send_message_enabled
  end

  def self.build_message(name, params = {})
    name = name.split(':') if name.is_a?(String)
    params.reverse_merge(
      name: name,
      triggered_by: 'zazo:api',
      triggered_at: DateTime.now.utc)
  end

  def self.emit(name, params = {})
    message = build_message(name, params)
    Rails.logger.info "[#{self}] Attemt to sent message to SQS queue #{queue_url}: #{message}"
    sqs_client.send_message(queue_url: queue_url, message_body: message.to_json) if send_message_enabled?
  end
end
