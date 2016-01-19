class HandleOutgoingVideo::DifferentFileSizesValidator < ActiveModel::Validator
  def validate(record)
    if record.s3_metadata.file_size && record.s3_metadata.file_size != record.s3_event.file_size
      HandleOutgoingVideo::StatusNotifier.new(record).rollbar :different_file_sizes
    end
  end
end
