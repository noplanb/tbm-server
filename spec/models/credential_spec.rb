# spec/models/credential.rb
require 'rails_helper'

RSpec.describe Credential, type: :model do
  subject { build(:credential) }
  it { is_expected.to be_valid }

  describe 'columns' do
    it { is_expected.to have_db_column(:cred_type).of_type(:string) }
    it { is_expected.to have_db_column(:cred).of_type(:text) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:cred_type) }
    it { is_expected.to validate_uniqueness_of(:cred_type) }
  end
end
