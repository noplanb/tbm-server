require 'rails_helper'

RSpec.describe Messages::Create do
  let(:user) { create(:user) }
  let(:receiver) { create(:user) }
  let(:default_params) do
    create(:established_connection, target: user, creator: receiver)
    { user: user, id: '123456789100', receiver_mkey: receiver.mkey, type: 'text' }
  end

  describe '.run' do
    def self.it_kvstore_item_value
      it do
        subject
        expected = {
          'messageId' => '123456789100', 'type' => 'text' }
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
      before { described_class.run(default_params.merge(type: 'video')) }

      it { expect { subject }.to change { Kvstore.count }.by(0) }
      it { expect(subject.valid?).to be_truthy }
      it_kvstore_item_value
    end
  end
end
