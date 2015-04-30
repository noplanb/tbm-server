require 'rails_helper'

RSpec.describe EventDispatcher do
  describe '.emit', event_dispatcher_enabled: true do
    let(:name) { 'zazo:test' }
    let(:params) do
      { initiator: 'user',
        initiator_id: '1' }
    end
    subject { described_class.emit(name, params) }
    around do |example|
      VCR.use_cassette('sqs_send_message', erb: {
                         queue_url: described_class.queue_url,
                         region: described_class.sqs_client.config.region,
                         access_key: described_class.sqs_client.config.credentials.access_key_id }) do
        example.run
      end
    end

    specify do
      is_expected.to be_a(Aws::PageableResponse)
    end
  end

  describe '.disable_send_message!', event_dispatcher_enabled: true do
    subject { described_class.disable_send_message! }
    specify do
      expect { subject }.to change { described_class.send_message_enabled? }.from(true).to(false)
    end
  end

  describe '.enable_send_message!' do
    subject { described_class.enable_send_message! }
    specify do
      expect { subject }.to change { described_class.send_message_enabled? }.from(false).to(true)
    end
  end
end
