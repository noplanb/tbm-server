class S3Credential < Credential
  include SpecificCredential

  define_attributes :region, :bucket, :access_key, :secret_key

  validates :region, allow_blank: true, inclusion: { in: region_list=%w(us-east-1 us-west-1 us-west-2 ap-southeast-1 ap-southeast-2 ap-northeast-1 sa-east-1), message: "must either: #{region_list.join(', ')}" }

end
