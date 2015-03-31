require 'rails_helper'

RSpec.describe GcmServer, type: :model do
  subject { described_class }
  let(:ids) { 'push_token' }
  let(:data) { { foo: 'bar' } }
  let(:payload) { { registration_ids: [ids], data: data } }

  describe '.make_payload' do
    subject { described_class.make_payload(ids, data) }
    it { is_expected.to eq(payload) }
  end

  describe '.send_notification' do
    subject { described_class.send_notification(ids, data) }

    context 'with server error' do
      specify do
        expect(Rollbar).to receive(:error)
        VCR.use_cassette('gcm_send_with_server_error', erb: {
                           key: 'gcmkey', payload: payload }) do
          subject
        end
      end
    end

    context 'with wrong registration_ids' do
      let(:response_body) do
        { 'multicast_id' => 4_843_761_582_852_144_534,
          'success' => 0,
          'failure' => 1,
          'canonical_ids' => 0,
          'results' =>
            [{ 'error' => 'InvalidRegistration' }] }
      end

      specify do
        VCR.use_cassette('gcm_send_with_error', erb: {
                           key: 'gcmkey', payload: payload }) do
          subject
        end
        is_expected.to be_a(Faraday::Response)
      end

      specify do
        expect(Rollbar).to receive(:warning).with(
          'GcmServer: GCM responded with errors: InvalidRegistration',
          gcm_response: response_body)
        VCR.use_cassette('gcm_send_with_error', erb: {
                           key: 'gcmkey', payload: payload }) do
          subject
        end
      end

      context 'body' do
        before do
          VCR.use_cassette('gcm_send_with_error', erb: {
                             key: 'gcmkey', payload: payload }) do
            subject
          end
        end
        subject { described_class.send_notification(ids, data).body }

        it { is_expected.to eq(response_body) }
      end
    end
  end
end
