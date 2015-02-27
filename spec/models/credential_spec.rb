# spec/models/credential.rb
require 'rails_helper'

RSpec.describe Credential, type: :model do
  subject { build(:credential) }
  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of(:cred_type) }
  it { is_expected.to validate_uniqueness_of(:cred_type) }
end
