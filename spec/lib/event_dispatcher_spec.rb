require 'rails_helper'

RSpec.describe EventDispatcher do
  describe '.emit' do
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
end
