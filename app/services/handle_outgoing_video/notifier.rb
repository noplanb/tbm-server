class HandleOutgoingVideo::Notifier
  ROLLBAR_MESSAGES = {
    zero_file_size: 'Upload with filesize == 0',
    different_file_sizes: 'Upload event with wrong size',
    duplication: 'Duplicate upload event'
  }

  attr_reader :instance

  def initialize(instance)
    @instance = instance
  end

  def rollbar(type)
    Rollbar.error ROLLBAR_MESSAGES[type], {
      s3_event:    instance.s3_event.inspect,
      s3_metadata: instance.s3_metadata.inspect
    } if ROLLBAR_MESSAGES[type]
  end
end
