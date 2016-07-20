require 'rails_helper'

RSpec.describe Api::V1::MessagesController::Update do
  let(:user) { create(:user) }
  let(:sender) { create(:user) }
  let(:default_params) do
    create(:established_connection, target: user, creator: sender)
    { user: user, id: '123456789100', sender_mkey: sender.mkey, type: 'text', status: 'downloaded' }
  end

  describe '.run' do
    def self.it_kvstore_item_value
      it do
        subject
        expected = {
          'messageId' => '123456789100', 'type' => 'text', 'status' => 'downloaded' }
        expect(JSON.parse(Kvstore.last.value)).to eq(expected)
      end
    end

    subject { described_class.run(default_params) }

    context 'when kvstore record is not exist' do
      it { expect { subject }.to change { Kvstore.count }.by(1) }
      it { expect(subject.valid?).to be_truthy }
      it_kvstore_item_value
    end

    context 'when kvstore record is already exist' do
      before { described_class.run(default_params.merge(type: 'video', status: 'uploaded')) }

      it { expect { subject }.to change { Kvstore.count }.by(0) }
      it { expect(subject.valid?).to be_truthy }
      it_kvstore_item_value
    end
  end

  describe 'validations' do
    subject { described_class.run(params).errors.full_messages }

    context 'status' do
      let(:params) { default_params.merge(status: 'incorrect') }

      it { is_expected.to eq(['Status incorrect is not allowed']) }
    end
  end
end
