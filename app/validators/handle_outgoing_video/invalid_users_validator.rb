class HandleOutgoingVideo::InvalidUsersValidator < ActiveModel::Validator
  def validate(record)
    users_not_found = ''
    users_not_found += "#{record.s3_metadata.sender_mkey}[User];" unless record.sender_user
    users_not_found += "#{record.s3_metadata.receiver_mkey}[User];" unless record.receiver_user
    users_not_found += "#{record.s3_metadata.receiver_mkey}[PushUser];" unless record.receiver_push_user

    unless users_not_found.empty?
      #HandleOutgoingVideo::StatusNotifier.new(record).rollbar :users_not_found, users: users_not_found
      record.errors.add :users, "these users are not found: #{users_not_found}"
    end
  end
end
