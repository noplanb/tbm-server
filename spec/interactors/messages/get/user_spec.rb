require 'rails_helper'

RSpec.describe Messages::Get::User do
  let(:user) { create(:user) }
  let(:default_params) { { mkey: user.mkey, relation: :sender } }

  describe '.run' do
    subject { described_class.run(default_params) }

    it { expect(subject.valid?).to be(true) }
    it { expect(subject.result).to eq(user) }
  end

  describe 'validations' do
    subject { described_class.run(params).errors.full_messages }

    context 'presence' do
      let(:params) { default_params.merge(mkey: 'xxxxxxxxxxxx') }

      it { is_expected.to eq(['Sender not found by mkey=xxxxxxxxxxxx']) }
    end
  end
end
