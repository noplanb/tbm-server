require 'rails_helper'

RSpec.describe HandleOutgoingVideo do
  use_vcr_cassette 'gcm_send_with_error', erb: {
    key: Figaro.env.gcm_api_key,
    payload: GcmServer.make_payload('qq64zz709r4zw1l6ap5p', type: 'video_received',
                                                            from_mkey: 'ZcAK4dM9S4m0IFui6ok6',
                                                            video_id: '1444235919617') }

  let(:s3_event_params) { json_fixture(s3_event_file)['Records'] }
  let(:instance) { described_class.new s3_event_params }

  RSpec.shared_examples 'expect common behavior' do |params|
    action   = -> (key) { params[:perform][key] ? :to : :to_not }
    metadata = { common_behavior: true }.merge(params[:addition_metadata] || {})

    it '#do', metadata do
      expect(subject).to be params[:perform][:do]
    end

    it 'notification case', metadata do
      expect_any_instance_of(Notification::SendMessage).send action.call(:notification), receive(:process)
      subject
    end

    it 'kvstore case', metadata do
      expect(Kvstore).send action.call(:kvstore), receive(:add_id_key)
      subject
    end
  end

  def create_users_and_connection(create_push_user = true)
    creator = FactoryGirl.create :user, mkey: 'ZcAK4dM9S4m0IFui6ok6'
    target  = FactoryGirl.create :user, mkey: 'lpb8DcispONUSfdMOT9g'
    FactoryGirl.create :push_user, mkey: target.mkey, push_token: 'qq64zz709r4zw1l6ap5p' if create_push_user
    FactoryGirl.create :established_connection, creator: creator, target: target
  end

  def stub_kvstore
    allow_any_instance_of(Kvstore::TriggerEvent).to receive(:call).and_return(true)
  end

  describe '#do' do
    let(:errors_messages) do
      HandleOutgoingVideo::StatusNotifier.new(instance).send(:errors_messages)
    end

    subject do
      VCR.use_cassette(vcr_cassette) { instance.do }
    end

    before do |example|
      if example.metadata[:common_behavior]
        create_users_and_connection !example.metadata[:disable_push_user]
        stub_kvstore
      end
      VCR.use_cassette(vcr_cassette) { instance.do } if example.metadata[:do_before]
    end

    context 'success case' do
      let(:vcr_cassette)  { 's3_get_metadata' }
      let(:s3_event_file) { 's3_event' }

      include_examples 'expect common behavior', perform: { do: true, kvstore: true, notification: true }

      it(nil, :common_behavior) { expect { subject }.to change { Kvstore.count }.by 1 }

      it 'specific kvstore placed in database', :common_behavior, :do_before do
        expect(Kvstore.last.key2).to eq '1444235919617'
      end

      it 'specific video_id stored in database', :common_behavior, :do_before do
        expect(NotifiedS3Object.last.file_name).to eq s3_event_params.first['s3']['object']['key']
      end
    end

    context 'duplication case' do
      let(:vcr_cassette)  { 's3_get_metadata' }
      let(:s3_event_file) { 's3_event' }

      before { FactoryGirl.create :notified_s3_object, file_name: s3_event_params.first['s3']['object']['key'] }

      include_examples 'expect common behavior', perform: { do: false, kvstore: false, notification: false }

      it 'has specific errors' do
        subject
        create_users_and_connection && stub_kvstore
        expect(errors_messages).to eq file_name: ['already persisted in database, duplication case']
      end

      it 'should fire rollbar error' do
        expect(Rollbar).to receive(:error).with 'Duplicate upload event', Hash
        subject
      end
    end

    context 'invalid mkeys case' do
      let(:vcr_cassette)  { 's3_get_metadata' }
      let(:s3_event_file) { 's3_event' }

      include_examples 'expect common behavior', perform: {
        do: true, kvstore: true, notification: false,
      }, addition_metadata: { disable_push_user: true }
    end

    context 'invalid s3_event case' do
      let(:vcr_cassette)  { 's3_get_metadata_incorrect' }
      let(:s3_event_file) { 's3_event_incorrect' }

      include_examples 'expect common behavior', perform: { do: false, kvstore: false, notification: false }

      it 'has specific errors', :do_before do
        expect(errors_messages).to eq bucket_name: ['can\'t be blank'],
                                      file_name:   ['can\'t be blank']
      end
    end

    context 'file sizes comparison', :common_behavior do
      let(:s3_event_file) { 's3_event' }

      after { subject }

      context 'equal' do
        let(:vcr_cassette) { 's3_get_metadata_file_sizes_same' }

        include_examples 'expect common behavior', perform: { do: true, kvstore: true, notification: true }

        it 'should not fire rollbar error' do
          expect(Rollbar).to_not receive(:error)
        end
      end

      context 'not equal' do
        let(:vcr_cassette) { 's3_get_metadata_file_sizes_different' }

        include_examples 'expect common behavior', perform: { do: true, kvstore: true, notification: true }

        it 'should fire rollbar error' do
          expect(Rollbar).to receive(:error).with 'Upload event with wrong size', Hash
        end
      end

      context 'when metadata does\'t contains file size' do
        let(:vcr_cassette) { 's3_get_metadata' }

        include_examples 'expect common behavior', perform: { do: true, kvstore: true, notification: true }

        it 'should not fire rollbar error' do
          expect(Rollbar).to_not receive(:error)
        end
      end
    end

    context 'file size equals zero' do
      let(:vcr_cassette)  { 's3_get_metadata' }
      let(:s3_event_file) { 's3_event_zero_file_size' }

      include_examples 'expect common behavior', perform: { do: false, kvstore: false, notification: false }

      it 'should fire rollbar error' do
        expect(Rollbar).to receive(:error).with 'Upload with filesize == 0', Hash
        subject
      end
    end
  end
end
