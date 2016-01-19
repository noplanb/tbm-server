class HandleOutgoingVideo::ZeroFileSizeValidator < ActiveModel::Validator
  def validate(record)
    unless record.s3_event.file_size > 0
      HandleOutgoingVideo::StatusNotifier.new(record).rollbar :zero_file_size
      record.errors.add :file_size, 'can\'t be zero, probably error with s3 upload'
    end
  end
end
