require 'rails_helper'

RSpec.describe Api::V1::EventsController, type: :controller do
  describe 'POST #create' do
    use_vcr_cassette 's3_get_metadata'
    before do
      allow_any_instance_of(Kvstore).to receive(:trigger_event).and_return true
      post :create, params
    end

    context 'correct s3 event' do
      let(:params) { json_fixture('s3_event') }
      it { expect(response).to have_http_status :ok }
    end

    context 'incorrect s3 event' do
      let(:params) { json_fixture('s3_event_incorrect') }
      it { expect(response).to have_http_status :unprocessable_entity }
    end
  end
end
