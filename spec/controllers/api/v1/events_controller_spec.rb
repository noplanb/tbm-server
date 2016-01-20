require 'rails_helper'

RSpec.describe Api::V1::EventsController, type: :controller do
  describe 'POST #create' do
    use_vcr_cassette 's3_get_metadata'

    before do
      creator = FactoryGirl.create :user, mkey: 'ZcAK4dM9S4m0IFui6ok6'
      target  = FactoryGirl.create :user, mkey: 'lpb8DcispONUSfdMOT9g'
      FactoryGirl.create :push_user, mkey: target.mkey, push_token: 'qq64zz709r4zw1l6ap5p'
      FactoryGirl.create :established_connection, creator: creator, target: target
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
    end
  end
end
