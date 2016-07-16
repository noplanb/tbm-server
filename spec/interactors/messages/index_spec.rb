require 'rails_helper'

RSpec.describe Messages::Index do
  include_context 'user prepared messages'

  let(:user) { create(:user) }

  describe '.run' do
    subject { described_class.run(user: user) }

    it { expect(subject.valid?).to be_truthy }
    it { expect(subject.result).to_not be_empty }
  end
end
