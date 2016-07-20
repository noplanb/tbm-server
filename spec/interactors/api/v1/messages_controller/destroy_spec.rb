require 'rails_helper'

RSpec.describe Api::V1::MessagesController::Destroy do
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
    it do
      subject
      expect { message.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
