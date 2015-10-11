require 'rails_helper'

RSpec.describe HandleOutgoingVideo do
  use_vcr_cassette 'gcm_send_with_error', erb: {
    key: Figaro.env.gcm_api_key,
    payload: GcmServer.make_payload(
      'qq64zz709r4zw1l6ap5p',
      type: 'video_received',
      from_mkey: 'ZcAK4dM9S4m0IFui6ok6',
      video_id: '1444235919617')
  }
  let(:instance) { described_class.new s3_event_params }

  describe '#do' do
    context 'success case' do
      use_vcr_cassette 's3_get_metadata'

      let(:s3_event_params) { json_fixture('s3_event')['Records'] }
      subject { instance.do }

      before do |example|
        creator = FactoryGirl.create :user, mkey: 'ZcAK4dM9S4m0IFui6ok6'
        target  = FactoryGirl.create :user, mkey: 'lpb8DcispONUSfdMOT9g'
        FactoryGirl.create :push_user, mkey: target.mkey, push_token: 'qq64zz709r4zw1l6ap5p'
        FactoryGirl.create :established_connection, creator: creator, target: target
        allow_any_instance_of(Kvstore).to receive(:trigger_event).and_return true
        instance.do if example.metadata[:do_before]
      end

      it { expect(subject).to be true }
      it { expect { subject }.to change { Kvstore.count }.by 1 }
      it 'specific kvstore placed in database', :do_before do
        expect = %w(ZcAK4dM9S4m0IFui6ok6-lpb8DcispONUSfdMOT9g-da6f35c931ea53de0e24fb4c76beb5f3-VideoIdKVKey 1444235919617)
        expect(Kvstore.pluck(:key1, :key2).last).to eq expect
      end
    end

    context 'invalid mkeys case' do
      use_vcr_cassette 's3_get_metadata'

      let(:s3_event_params) { json_fixture('s3_event')['Records'] }
      subject { instance.do }

      before { |example| instance.do if example.metadata[:do_before] }

      it { expect(subject).to be false }
      it 'has specific errors', :do_before do
        expect = { mkeys: ['couldn\'t find user by mkey'] }
        expect(instance.errors).to eq expect
      end
    end

    context 'invalid s3_event case' do
      use_vcr_cassette 's3_get_metadata_incorrect'

      let(:s3_event_params) { json_fixture('s3_event_incorrect')['Records'] }
      subject { instance.do }

      before { |example| instance.do if example.metadata[:do_before] }

      it { expect(subject).to be false }
      it 'has specific errors', :do_before do
        expect = { bucket_name: ['can\'t be blank'], file_name: ['can\'t be blank'] }
        expect(instance.errors).to eq expect
      end
    end
  end
end
