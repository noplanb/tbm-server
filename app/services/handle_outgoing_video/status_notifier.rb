class HandleOutgoingVideo::StatusNotifier
  ROLLBAR_MESSAGES = {
    zero_file_size: 'Upload with filesize == 0',
    different_file_sizes: 'Upload event with wrong size',
    duplication: 'Duplicate upload event',
    users_not_found: 'User or PushUser not found'
  }

  attr_reader :instance

  def initialize(instance)
    @instance = instance
  end

  def rollbar(type, data = {})
    if ROLLBAR_MESSAGES[type]
      Rollbar.error ROLLBAR_MESSAGES[type], rollbar_data(data)
    end
  end

  def log_messages(status)
    case status
      when :success then Zazo::Tool::Logger.info(self, "s3 event was handled successfully at #{Time.now}; #{debug_info}")
      when :failure then Zazo::Tool::Logger.info(self, "errors occurred with handle s3 event at #{Time.now}; errors: #{errors_messages.inspect}; #{debug_info}")
    end
  end

  private

  def rollbar_data(data)
    data.merge s3_event:    instance.s3_event.inspect,
               s3_metadata: instance.s3_metadata.inspect
  end

  def debug_info
    "s3 event: #{instance.s3_event.inspect}; s3 metadata: #{instance.s3_metadata.inspect}"
  end

  def errors_messages
    instance.errors.messages.merge instance.s3_event.errors.messages
  end
end
