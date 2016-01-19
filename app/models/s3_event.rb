class S3Event
  include ActiveModel::Validations

  attr_accessor         :bucket_name, :file_name, :file_size
  validates_presence_of :bucket_name, :file_name, :file_size

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
end
