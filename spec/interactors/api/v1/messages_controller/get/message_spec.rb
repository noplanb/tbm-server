require 'rails_helper'

RSpec.describe Api::V1::MessagesController::Get::Message do
  let(:user) { create(:user) }
  let(:message) do
    friend = create(:user)
    create(:established_connection, creator: user, target: friend)
    Kvstore.add_message_id_key('video', friend, user, gen_message_id)
  end
  let(:default_params) { { user: user, id: message.key2 } }

  describe '.run' do
    subject { described_class.run(default_params) }

    it { expect(subject.valid?).to be_truthy }
    it { expect(subject.result).to eq(message) }
  end

  describe 'validations' do
    subject { described_class.run(params).errors.full_messages }

    context 'presence' do
      let(:params) { default_params.merge(id: '123456789100') }

      it { is_expected.to eq(['Message not found by key2=123456789100 by user ownership']) }
    end

    context 'ownership' do
      let(:params) { default_params.merge(user: create(:user)) }

      it { is_expected.to eq(["Message not found by key2=#{message.key2} by user ownership"]) }
    end
  end
end
