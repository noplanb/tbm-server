class HandleOutgoingVideo::SameFileSizesValidator < ActiveModel::Validator
  def validate(record)
    if record.s3_metadata.file_size && record.s3_metadata.file_size != record.s3_event.file_size
      Rollbar.error 'Upload event with wrong size', s3_event:    record.s3_event.inspect,
                                                    s3_metadata: record.s3_metadata.inspect
      #record.errors.add :file_size, 'file sizes different between metadata and event data'
    end
  end
end
