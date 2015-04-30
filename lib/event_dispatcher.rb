class EventDispatcher
  def self.queue_url
    Figaro.env.sqs_queue_url
  end

  def self.sqs_client
    @sqs_client ||= Aws::SQS::Client.new
  end

  def self.emit(name, params = {})
    message_body = params.reverse_merge(
      name: name,
      triggered_by: 'zazo:api',
      triggered_at: DateTime.now.utc).to_json
    Rails.logger.info "[#{self}] Attemt to sent message to SQS queue #{queue_url}: #{message_body}"
    sqs_client.send_message(queue_url: queue_url, message_body: message_body)
  end
end
