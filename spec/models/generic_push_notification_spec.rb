require 'rails_helper'

RSpec.describe GenericPushNotification, type: :model do
  let(:user) { create(:user) }
  let(:target_push_user) { build(:push_user) }
  let(:video_id) { (Time.now.to_f * 1000).to_i.to_s }
  let(:attributes) do
    {  platform: target_push_user.device_platform,
       build: target_push_user.device_build,
       token: target_push_user.push_token,
       type: :alert,
       payload: { type: 'video_received',
                  from_mkey: user.mkey,
                  video_id: video_id },
       alert: "New message from #{user.name}",
       content_available: true
     }
  end

  let(:instance) { described_class.new(attributes) }
  let(:ios_notification) do
    n = Houston::Notification.new(attributes.slice(:token,
                                                  :alert,
                                                  :badge,
                                                  :content_available))
    n.custom_data = attributes[:payload]
    n.sound = 'NotificationTone.wav'
    n
  end

  describe '#send' do
    subject { instance.send }

    context 'Android' do
      let(:target_push_user) { build(:android_push_user) }
      let(:payload) do
        GcmServer.make_payload(attributes[:token], attributes[:payload])
      end

      specify do
        expect(GcmServer).to receive(:send_notification).with(attributes[:token],
                                                              attributes[:payload])
        VCR.use_cassette('gcm_send_with_error',
                         erb: { key: Figaro.env.gcm_api_key, payload: payload }) do
          subject
        end
      end
    end

    context 'iOS' do
      let(:target_push_user) { build(:ios_push_user) }

      specify 'expects any instance of Houston::Client receives :push' do
        allow(instance).to receive(:ios_notification).and_return(ios_notification)
        expect_any_instance_of(Houston::Client).to receive(:push).with(ios_notification)
        subject
      end
    end
  end

  describe '#ios_notification' do
    subject { instance.ios_notification }
    it { is_expected.to be_valid }
  end

  describe '#feedback' do
    context 'iOS' do
      let(:target_push_user) { build(:ios_push_user) }
      before { instance.send }
      it { expect(instance.feedback).to eq([]) }
    end
  end
end
