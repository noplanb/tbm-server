require 'rails_helper'

RSpec.describe HandleOutgoingVideo do
  use_vcr_cassette 'gcm_send_with_error',
    erb: {
      key: Figaro.env.gcm_api_key,
      payload: GcmServer.make_payload('qq64zz709r4zw1l6ap5p',
        type: 'video_received',
        from_mkey: 'ZcAK4dM9S4m0IFui6ok6',
        video_id: '1444235919617') }

  let(:s3_event_params) { json_fixture(s3_event_file)['Records'] }
  let(:instance) { described_class.new(s3_event_params) }

  def self.with_metadata(*args)
    [nil] + args
  end

  RSpec.shared_examples 'expect common behavior' do |params|
    action = -> (key) { params[:perform][key] ? :to : :to_not }
    metadata = { common_behavior: true }.merge(params[:addition_metadata] || {})

    it '#do', metadata do
      expect(subject).to be(params[:perform][:do])
    end

    it 'notification case', metadata do
      expect_any_instance_of(Notification::SendMessage).send(
        action.call(:notification), receive(:process))
      subject
    end

    it 'kvstore case', metadata do
      expect(Kvstore).send(action.call(:kvstore), receive(:add_id_key))
      subject
    end
  end

  describe '#do' do
    def create_users_and_connection(create_push_user = true)
      creator = FactoryGirl.create(:user, mkey: 'ZcAK4dM9S4m0IFui6ok6')
      target = FactoryGirl.create(:user, mkey: 'lpb8DcispONUSfdMOT9g')
      FactoryGirl.create(:push_user, mkey: target.mkey, push_token: 'qq64zz709r4zw1l6ap5p') if create_push_user
      FactoryGirl.create(:established_connection, creator: creator, target: target)
    end

    subject { VCR.use_cassette(vcr_cassette) { instance.do } }

    before do |example|
      create_users_and_connection(!example.metadata[:disable_push_user]) if example.metadata[:common_behavior]
      subject if example.metadata[:do_before]
    end

    after do |example|
      subject if example.metadata[:do_after]
    end

    context 'when success' do
      let(:vcr_cassette)  { 's3_get_metadata' }
      let(:s3_event_file) { 's3_event' }

      include_examples 'expect common behavior',
        perform: { do: true, kvstore: true, notification: true }
      it *with_metadata(:common_behavior) do
        expect { subject }.to change { Kvstore.count }.by(1)
      end
      it *with_metadata(:common_behavior, :do_before) do
        expect(Kvstore.last.key2).to eq('1444235919617')
      end
      it *with_metadata(:common_behavior, :do_before) do
        expect(NotifiedS3Object.last.file_name).to eq(s3_event_params.first['s3']['object']['key'])
      end
      it *with_metadata(:common_behavior, :do_before) do
        expect(SidekiqWorker::TranscriptVideoMessage).to be_processed_in(:default)
      end
    end

    context 'when failure' do
      let(:errors_messages) do
        HandleOutgoingVideo::StatusNotifier.new(instance).send(:errors_messages)
      end

      context 'duplication case' do
        let(:vcr_cassette)  { 's3_get_metadata' }
        let(:s3_event_file) { 's3_event' }

        before do
          FactoryGirl.create(:notified_s3_object,
            file_name: s3_event_params.first['s3']['object']['key'])
        end

        include_examples 'expect common behavior',
          perform: { do: false, kvstore: false, notification: false }
        it do
          subject
          create_users_and_connection
          expect(errors_messages).to eq(file_name: ['already persisted in database, duplication case'])
        end
        it *with_metadata(:do_after) do
          expect(Rollbar).to receive(:error).with('Duplicate upload event', Hash)
        end
      end

      context 'invalid mkeys case' do
        let(:vcr_cassette)  { 's3_get_metadata' }
        let(:s3_event_file) { 's3_event' }

        include_examples 'expect common behavior',
          perform: { do: true, kvstore: true, notification: false },
          addition_metadata: { disable_push_user: true }
      end

      context 'invalid s3_event case' do
        let(:vcr_cassette)  { 's3_get_metadata_incorrect' }
        let(:s3_event_file) { 's3_event_incorrect' }

        include_examples 'expect common behavior',
          perform: { do: false, kvstore: false, notification: false }
        it *with_metadata(:do_before) do
          expected = { bucket_name: ['can\'t be blank'], file_name: ['can\'t be blank'] }
          expect(errors_messages).to eq(expected)
        end
      end

      context 'file sizes comparison', :common_behavior do
        let(:s3_event_file) { 's3_event' }

        after { subject }

        context 'equal' do
          let(:vcr_cassette) { 's3_get_metadata_file_sizes_same' }

          include_examples 'expect common behavior',
            perform: { do: true, kvstore: true, notification: true }
          it { expect(Rollbar).to_not receive(:error) }
        end

        context 'not equal' do
          let(:vcr_cassette) { 's3_get_metadata_file_sizes_different' }

          include_examples 'expect common behavior',
            perform: { do: true, kvstore: true, notification: true }
          it { expect(Rollbar).to receive(:error).with('Upload event with wrong size', Hash) }
        end

        context 'when metadata does\'t contains file size' do
          let(:vcr_cassette) { 's3_get_metadata' }

          include_examples 'expect common behavior',
            perform: { do: true, kvstore: true, notification: true }
          it { expect(Rollbar).to_not receive(:error) }
        end
      end

      context 'file size equals zero' do
        let(:vcr_cassette)  { 's3_get_metadata' }
        let(:s3_event_file) { 's3_event_zero_file_size' }

        include_examples 'expect common behavior',
          perform: { do: false, kvstore: false, notification: false }
        it *with_metadata(:do_after) do
          expect(Rollbar).to receive(:error).with('Upload with filesize == 0', Hash)
        end
      end
    end
  end
end
