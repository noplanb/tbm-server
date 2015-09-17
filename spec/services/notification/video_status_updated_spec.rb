require 'rails_helper'

RSpec.describe Notification::VideoStatusUpdated, type: :service do
  let(:video_id) { (Time.now.to_f * 1000).to_i.to_s }
  let(:sender) { create(:android_user) }
  let(:receiver) { create(:ios_user) }
  let(:target) do
    create(:push_user,
           mkey: user.mkey,
           device_platform: user.device_platform)
  end
  let(:push_user_params) do
    { mkey: target.mkey,
      push_token: 'push_token',
      device_platform: target.device_platform.to_s,
      device_build: 'dev' }
  end
  let(:video_filename) { Kvstore.video_filename(sender, receiver, video_id) }
  let(:push_user) { create(:push_user, push_user_params) }
  let(:host) { 'test.host' }
  let(:instance) { described_class.new(push_user, host) }

  before { create(:established_connection, creator: sender, target: receiver) }

  describe '#process' do
    let(:user) { sender }
    let(:params) do
      push_user_params.merge(to_mkey: receiver.mkey,
                             target_mkey: target.mkey,
                             video_id: video_id,
                             status: 'viewed')
    end
    let(:attributes) do
      { type: :silent,
        payload: { type: 'video_status_update',
                   to_mkey: params[:to_mkey],
                   status: params[:status],
                   video_id: params[:video_id],
                   host: host } }
    end
    subject { instance.process(params) }

    it 'expects any instance of PushUser receives :send_notification with valid attributes' do
      expect_any_instance_of(PushUser).to receive(:send_notification).with(attributes)
      subject
    end

    describe 'event notification' do
      let(:event_params) do
        { initiator: 'user',
          initiator_id: user.mkey,
          target: 'video',
          target_id: video_filename,
          data: {
            sender_id: params[:target_mkey],
            sender_platform: sender.device_platform,
            receiver_id: params[:to_mkey],
            receiver_platform: receiver.device_platform,
            video_filename: video_filename,
            video_id: video_id
          },
          raw_params: params }
      end

      subject do
        allow(GenericPushNotification).to receive(:send_notification)
        instance.process(params)
      end
      it_behaves_like 'event dispatchable', %w(video notification viewed)
    end

    context 'Android' do
      let(:sender) { create(:android_user) }
      let(:payload) do
        GcmServer.make_payload(
          params[:push_token],
          type: 'video_status_update',
          to_mkey: params[:to_mkey],
          status: params[:status],
          video_id: params[:video_id])
      end

      specify 'expects GenericPushNotification to receive :send_notification' do
        expect(GenericPushNotification).to receive(:send_notification)
        VCR.use_cassette('gcm_send_with_error', erb: {
                           key: Figaro.env.gcm_api_key, payload: payload }) do
          subject
        end
      end
    end

    context 'iOS' do
      let(:sender) { create(:ios_user) }

      specify 'expects GenericPushNotification to receive :send_notification' do
        expect(GenericPushNotification).to receive(:send_notification)
        subject
      end
    end
  end
end
