class S3Credential < SpecificCredential
  
  CRED_TYPE = "s3"
  ATTRIBUTES = [:region, :bucket, :access_key, :secret_key]
  
  # TODO: Alex show me how this can be written only in the super and not have to be copied here.
  ATTRIBUTES.each do |a| 
    attr_accessor a
  end
  
  validates :region, allow_blank: true, inclusion: { in: region_list=%w(us-east-1 us-west-1 us-west-2 ap-southeast-1 ap-southeast-2 ap-northeast-1 sa-east-1), message: "must either: #{region_list.join(', ')}" }
  
  def only_app_attributes
    r = {}
    ATTRIBUTES.each do |a| 
      r[a] = send(a)
    end
  end
  
  
end
