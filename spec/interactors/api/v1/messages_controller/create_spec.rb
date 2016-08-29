require 'rails_helper'

RSpec.describe Api::V1::MessagesController::Create do
  let(:user) { create(:user) }
  let(:receiver) { create(:user) }
  let(:default_params) do
    create(:established_connection, target: user, creator: receiver)
    { user: user, id: '123456789100', receiver_mkey: receiver.mkey, type: 'text' }
  end
  let(:params) { default_params }

  describe '.run' do
    def self.shared_context_specs
      it { expect(subject.valid?).to be_truthy }
      it do
        subject
        expected = {
          'messageId' => '123456789100', 'type' => 'text' }
        expect(JSON.parse(Kvstore.last.value)).to eq(expected)
      end
    end

    subject { described_class.run(params) }

    context 'when kvstore record is not exist' do
      it { expect { subject }.to change { Kvstore.count }.by(1) }
      shared_context_specs
    end

    context 'when kvstore record is already exist' do
      before { described_class.run(default_params.merge(type: 'video')) }

      it { expect { subject }.to change { Kvstore.count }.by(0) }
      shared_context_specs
    end

    context 'when id is not persisted is request' do
      let(:params) { default_params.except(:id) }

      it { expect(subject.valid?).to be_truthy }
      it do
        time = DateTime.parse('21-01-1994')
        Timecop.freeze(time) { subject }
        expected = {
          'messageId' => time.strftime('%Q'), 'type' => 'text' }
        expect(JSON.parse(Kvstore.last.value)).to eq(expected)
      end
    end
  end
end
