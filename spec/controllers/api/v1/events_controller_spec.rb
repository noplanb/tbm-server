require 'rails_helper'

RSpec.describe Api::V1::EventsController, type: :controller do
  describe 'POST #create' do
    use_vcr_cassette 's3_get_metadata'

    before do
      allow(EventDispatcher).to receive(:resend_s3_event).and_return true
      allow_any_instance_of(HandleOutgoingVideo).to receive(:send_notification_to_receiver).and_return true
      allow_any_instance_of(Kvstore).to receive(:trigger_event).and_return true
      post :create, params
    end

    context 'correct s3 event' do
      let(:params) { json_fixture('s3_event') }
      it { expect(response).to have_http_status :ok }
    end

    context 'incorrect s3 event' do
      let(:params) { json_fixture('s3_event_incorrect') }
      it { expect(response).to have_http_status :ok }
      it do
        expect = { 'errors' => { 'bucket_name' => ['can\'t be blank'], 'file_name' => ['can\'t be blank'] } }
        expect(JSON.parse(response.body)).to eq expect
      end
    end
  end
end
