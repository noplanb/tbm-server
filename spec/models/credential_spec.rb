# spec/models/credential.rb
require 'spec_helper'

describe Credential do
  
  it "has a valid factory" do
    create(:credential).should be_valid
  end
  
  it { should validate_presence_of :cred_type }
  it { should validate_uniqueness_of :cred_type }

end
