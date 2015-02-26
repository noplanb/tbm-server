require 'spec_helper'

describe S3Credential do  
  S3Credential::ATTRIBUTES.each do |a|
    it { should validate_presence_of(a) }
  end
  
  it "should have getters and setters for all its attributes" do
    attrs = S3Credential::ATTRIBUTES
    attrs.should match_array [:region, :access_key, :secret_key, :bucket]
    attrs.each do |a|
      S3Credential.method_defined?(a).should_not be_nil
      S3Credential.method_defined?((a.to_s + "=").to_sym).should_not be_nil
    end
    
  end


  it do
      should validate_inclusion_of(:region).in_array(%w(us-east-1 us-west-1 us-west-2 ap-southeast-1 ap-southeast-2 ap-northeast-1 sa-east-1))
  end
  
  it "should be able to create and retrieve an instance with all attributes populated" do
    sc = S3Credential.instance
    sc.cred_type.should == S3Credential::CRED_TYPE

    sc.region = "us-east-1"
    sc.bucket = "bucket"
    sc.access_key = "access_key"
    sc.secret_key = "secret_key"

    sc.save.should be_truthy
    
    sc = S3Credential.instance
    sc.region.should == "us-east-1"
    sc.bucket.should == "bucket"
    sc.access_key.should == "access_key"
    sc.secret_key.should == "secret_key"
  end
  
end