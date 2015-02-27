require 'rails_helper'

# Model for test credentials
class TestCredential < Credential
  include SpecificCredential
  define_attributes :foo, :bar
end

RSpec.describe SpecificCredential, type: :model do
  subject { TestCredential }

  it { is_expected.to respond_to(:credentail_attributes) }
  pending 'TODO: write more'
end
