class EventDispatcher
  def self.queue_url
    Figaro.env.sqs_queue_url
  end

  def self.sqs_client
    @sqs_client ||= Aws::SQS::Client.new
  end

  def self.emit(name, params = {})
    message = params.reverse_merge(
      name: name,
      triggered_by: 'zazo:api',
      triggered_at: Time.now.utc)
    sqs_client.send_message(queue_url: queue_url, message_body: message.to_json)
  end
end
