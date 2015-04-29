require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  before { authenticate_with_http_basic }
  # before { allow(subject).to receive(:put_s3_object).and_return(double('AWS::S3::Object')) }

  describe 'GET #receive_test_video' do
    let(:video_id) { '1429630398758' }
    let(:user) { create(:user) }
    let(:sender) { create(:user) }
    let!(:s3_credential) do
      cred = S3Credential.instance
      cred.update_credentials(region: 'us-west-1',
                              bucket: 'bucket',
                              access_key: 'access_key',
                              secret_key: 'secret_key')
      cred
    end
    let(:params) { { id: user.id, sender_id: sender.id } }
    let(:attributes) do
      { type: :alert,
        badge: 1,
        payload: { type: 'video_received',
                   from_mkey: sender.mkey,
                   video_id: video_id,
                   host: 'test.host' },
        alert: "New message from #{sender.first_name}" }
    end

    before { allow(controller).to receive(:test_video_id).and_return(video_id) }

    around do |example|
      Connection.find_or_create(user.id, sender.id)
      VCR.use_cassette('s3_put_video', erb: {
                         region: s3_credential.region,
                         bucket: s3_credential.bucket,
                         access_key: s3_credential.access_key,
                         secret_key: s3_credential.secret_key,
                         key: Kvstore.video_filename(sender, user, video_id)
                       }) do
          example.run
      end
    end

    context 'when push user exists' do
      let!(:push_user) do
        PushUser.create_or_update(mkey: user.mkey,
                                  device_platform: user.device_platform,
                                  push_token: 'push_token')
      end

      before { allow_any_instance_of(GenericPushNotification).to receive(:send_notification).and_return(true) }

      it 'expects any instance of PushUser receives :send_notification with valid attributes' do
        expect_any_instance_of(PushUser).to receive(:send_notification).with(attributes)
        get :receive_test_video, params
      end

      specify do
        get :receive_test_video, params
        expect(response).to redirect_to(user)
      end
    end

    context 'when push user not exists' do
      specify  do
        expect { get :receive_test_video, params }.to raise_error(ActionController::RoutingError)
      end
    end
  end

  describe 'GET #establish_connection' do
    let(:creator) { create(:user) }
    let(:target) { create(:user) }
    let(:params) { { id: creator.to_param, target_id: target.to_param } }

    context 'connection status' do
      specify do
        get :establish_connection, params
        connection = Connection.between(creator.id, target.id).first
        expect(connection.status).to eq('established')
      end
    end
  end
end
