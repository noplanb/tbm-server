class S3Event
  include ActiveModel::Validations

  attr_accessor :bucket_name, :file_name, :file_size

  validates_presence_of :bucket_name, :file_name, :file_size
  validate :file_size_should_not_be_zero, if: Proc.new { |e| !e.errors.key?(:file_size) }
  validate :file_name_should_be_uniq,     if: Proc.new { |e| !e.errors.key?(:file_name) }

  def initialize(params = [])
    params = params.first['s3']
    self.bucket_name = params['bucket']['name']
    self.file_name   = params['object']['key']
    self.file_size   = params['object']['size'].to_i
  rescue TypeError, NoMethodError
    nil
  end

  def inspect
    { bucket_name: bucket_name, file_name: file_name, file_size: file_size }.inspect
  end

  private

  def file_size_should_not_be_zero
    errors.add :file_size, 'can\'t be zero, probably error with s3 upload' unless file_size > 0
  end

  def file_name_should_be_uniq
    errors.add :file_name, 'already persisted in database, duplication case' if NotifiedS3Object.persisted? file_name
  end
end
