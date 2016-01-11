require 'rails_helper'

RSpec.describe HandleOutgoingVideo do
  use_vcr_cassette 'gcm_send_with_error', erb: {
    key: Figaro.env.gcm_api_key,
    payload: GcmServer.make_payload('qq64zz709r4zw1l6ap5p', type: 'video_received',
                                                            from_mkey: 'ZcAK4dM9S4m0IFui6ok6',
                                                            video_id: '1444235919617') }

  let(:s3_event_params) { json_fixture(s3_event_file)['Records'] }
  let(:instance) { described_class.new s3_event_params }

  def create_users_and_connection
    creator = FactoryGirl.create :user, mkey: 'ZcAK4dM9S4m0IFui6ok6'
    target  = FactoryGirl.create :user, mkey: 'lpb8DcispONUSfdMOT9g'
    FactoryGirl.create :push_user, mkey: target.mkey, push_token: 'qq64zz709r4zw1l6ap5p'
    FactoryGirl.create :established_connection, creator: creator, target: target
  end

  def stub_kvstore
    allow_any_instance_of(Kvstore).to receive(:trigger_event).and_return true
  end

  describe '#do' do
    subject do
      VCR.use_cassette(vcr_cassette) { instance.do }
    end

    before do |example|
      create_users_and_connection && stub_kvstore  if example.metadata[:common_behavior]
      VCR.use_cassette(vcr_cassette) { instance.do if example.metadata[:do_before] }
    end

    context 'success case' do
      let(:vcr_cassette)  { 's3_get_metadata' }
      let(:s3_event_file) { 's3_event' }

      it(nil, :common_behavior) { expect(subject).to be true }
      it(nil, :common_behavior) { expect { subject }.to change { Kvstore.count }.by 1 }

      it 'specific kvstore placed in database', :common_behavior, :do_before do
        expect(Kvstore.last.key2).to eq '1444235919617'
      end

      it 'specific video_id stored in database', :common_behavior, :do_before do
        expect(NotifiedS3Object.last.file_name).to eq s3_event_params.first['s3']['object']['key']
      end
    end

    context 'invalid mkeys case' do
      let(:vcr_cassette)  { 's3_get_metadata' }
      let(:s3_event_file) { 's3_event' }

      it { expect(subject).to be false }

      it 'has specific errors', :do_before do
        expect(instance.errors).to eq 'ActiveRecord::RecordNotFound' => 'Couldn\'t find User'
      end
    end

    context 'invalid s3_event case' do
      let(:vcr_cassette)  { 's3_get_metadata_incorrect' }
      let(:s3_event_file) { 's3_event_incorrect' }

      it { expect(subject).to be false }

      it 'has specific errors', :do_before do
        expect(instance.errors).to eq bucket_name: ['can\'t be blank'],
                                      file_name:   ['can\'t be blank'],
                                      file_size:   ['can\'t be zero, probably error with s3 upload']
      end
    end
  end
end
