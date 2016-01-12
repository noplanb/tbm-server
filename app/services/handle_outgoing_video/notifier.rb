class HandleOutgoingVideo::Notifier
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

  def rollbar(type, additional = {})
    if ROLLBAR_MESSAGES[type]
      Rollbar.error ROLLBAR_MESSAGES[type], rollbar_data(additional)
    end
  end

  private

  def rollbar_data(data)
    data.merge s3_event:    instance.s3_event.inspect,
               s3_metadata: instance.s3_metadata.inspect
  end
end
