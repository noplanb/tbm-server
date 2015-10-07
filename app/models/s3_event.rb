class S3Event
  include ActiveModel::Validations

  attr_accessor :bucket_name, :file_name

  validates_presence_of :bucket_name, :file_name

  def initialize(params = [])
    params = params.first['s3']
    self.bucket_name = params['bucket']['name']
    self.file_name   = params['object']['key']
  rescue TypeError, NoMethodError
    nil
  end
end
