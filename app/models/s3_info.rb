class S3Info
  
  TYPE = "s3"
  
  attr_accessor :region, :bucket, :access_key, :secret_key
    
  validates :region, inclusion: { in: region_list=%w(us-east-1 us-west-1 us-west-2 ap-southeast-1 ap-southeast-2 ap-northeast-1 sa-east-1), message: "must either: #{region_list.join(', ')}" }
  validates :region, :bucket, :access_key, :secret_key, presence: true
  
  def only_app_attributes
    attributes.symbolize_keys.slice(:bucket, :access_key, :secret_key, :region)
  end
  
  def all
    Credential.where(cred_type: TYPE)
  end
  
end
