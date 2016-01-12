class HandleOutgoingVideo::DuplicationCaseValidator < ActiveModel::Validator
  def validate(record)
    if NotifiedS3Object.persisted? record.s3_event.file_name
      Rollbar.error 'Duplicate upload event', s3_event:    record.s3_event.inspect,
                                              s3_metadata: record.s3_metadata.inspect
      record.errors.add :file_name, 'already persisted in database, duplication case'
    end
  end
end
