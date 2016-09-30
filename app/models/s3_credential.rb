# abstract class

class S3Credential < Credential
  include SpecificCredential

  REGION_LIST = %w(us-east-1 us-west-1 us-west-2 ap-southeast-1 ap-southeast-2 ap-northeast-1 sa-east-1).freeze

  define_attributes :region, :bucket, :access_key, :secret_key

  validates :region, allow_blank: true, inclusion:
    { in: REGION_LIST, message: "must either: #{REGION_LIST.join(', ')}" }

  def self.by_type(type)
    Zazo::Tool::Classifier.new([:s3_credential, type]).klass.instance
  rescue NameError
    fail "S3 credential not found by type: #{type}"
  end

  def s3_client
    @s3_client ||= Aws::S3::Client.new(region: region, access_key_id: access_key, secret_access_key: secret_key)
  end
end
