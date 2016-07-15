require 'rails_helper'

RSpec.describe Messages::Get::Connection do
  let(:user_1) { create(:user) }
  let(:user_2) { create(:user) }
  let(:default_params) { { user_1: user_1, user_2: user_2 } }
  let!(:connection) { create(:connection, creator: user_1, target: user_2) }

  describe '.run' do
    subject { described_class.run(default_params) }

    it { expect(subject.valid?).to be(true) }
    it { expect(subject.result).to eq(connection) }
  end

  describe 'validations' do
    subject { described_class.run(params).errors.full_messages }

    context 'presence' do
      let(:params) { default_params.merge(user_2: create(:user)) }

      it { is_expected.to eq(['Connection not found between users']) }
    end
  end
end
