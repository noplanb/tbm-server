require 'rails_helper'

RSpec.describe Messages::Get::Type do
  let(:default_params) { { type: 'video' } }

  describe '.run' do
    subject { described_class.run(default_params) }

    it { expect(subject.valid?).to be_truthy }
    it { expect(subject.result).to eq('video') }
  end

  describe 'validations' do
    subject { described_class.run(params).errors.full_messages }

    context 'inclusion' do
      let(:params) { { type: 'incorrect' } }

      it { is_expected.to eq(['Type incorrect is not allowed']) }
    end
  end
end
