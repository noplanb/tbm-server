class HandleOutgoingVideo::DuplicationCaseValidator < ActiveModel::Validator
  def validate(record)
    if NotifiedS3Object.persisted? record.s3_event.file_name
      HandleOutgoingVideo::StatusNotifier.new(record).rollbar :duplication
      record.errors.add :file_name, 'already persisted in database, duplication case'
    end
  end
end
