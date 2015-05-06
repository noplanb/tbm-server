require 'rails_helper'

RSpec.describe NotificationController, type: :controller do
  let(:video_id) { (Time.now.to_f * 1000).to_i.to_s }
  let(:sender) { create(:user) }
  let(:receiver) { create(:user) }
  let(:target) do
    create(:push_user,
           mkey: user.mkey,
           device_platform: user.device_platform)
  end
  let(:push_user_params) do
    { mkey: target.mkey,
      push_token: 'push_token',
      device_platform: target.device_platform,
      device_build: 'dev' }
  end
  let(:video_filename) { Kvstore.video_filename(sender, receiver, video_id) }

  before { create(:established_connection, creator: sender, target: receiver) }

  describe 'POST #set_push_token' do
    let(:user) { sender }
    let(:params) { push_user_params }
    before do
      authenticate_with_http_digest(user.mkey, user.auth) do
        post :set_push_token, params
      end
    end
    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #send_video_received' do
    let(:user) { receiver }
    let(:params) do
      push_user_params.merge(from_mkey: sender.mkey,
                             target_mkey: target.mkey,
                             sender_name: sender.first_name,
                             video_id: video_id)
    end
    let(:attributes) do
      { type: :alert,
        alert: "New message from #{params[:sender_name]}",
        badge: 1,
        payload: { type: 'video_received',
                   from_mkey: params[:from_mkey],
                   video_id: params[:video_id],
                   host: 'test.host' } }
    end

    it 'expects any instance of PushUser receives :send_notification with valid attributes' do
      expect_any_instance_of(PushUser).to receive(:send_notification).with(attributes)
      authenticate_with_http_digest(user.mkey, user.auth) do
        post :send_video_received, params
      end
    end

    context 'target_mkey not given' do
      let(:params) { {} }
      before do
        authenticate_with_http_digest(user.mkey, user.auth) do
          post :send_video_received, params
        end
      end
      it 'returns http not_found' do
        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'event notification' do
      let(:event_params) do
        { initiator: 'user',
          initiator_id: user.mkey,
          target: 'video',
          target_id: video_filename,
          data: {
            sender_id: params[:from_mkey],
            receiver_id: params[:target_mkey],
            video_filename: video_filename,
            video_id: video_id
          },
          raw_params: params.stringify_keys }
      end

      subject do
        allow(GenericPushNotification).to receive(:send_notification)
        authenticate_with_http_digest(user.mkey, user.auth) do
          post :send_video_received, params
        end
      end
      it_behaves_like 'event dispatchable', %w(video notification received)
    end

    context 'Android' do
      let(:receiver) { create(:android_user) }
      let(:payload) do
        GcmServer.make_payload(
          params[:push_token],
          type: 'video_received',
          from_mkey: params[:from_mkey],
          video_id: params[:video_id])
      end

      specify 'expects GenericPushNotification to receive :send_notification' do
        expect(GenericPushNotification).to receive(:send_notification)
        authenticate_with_http_digest(user.mkey, user.auth) do
          VCR.use_cassette('gcm_send_with_error', erb: {
                             key: Figaro.env.gcm_api_key, payload: payload }) do
            post :send_video_received, params
          end
        end
      end

      context 'response' do
        before do
          authenticate_with_http_digest(user.mkey, user.auth) do
            VCR.use_cassette('gcm_send_with_error', erb: {
                               key: Figaro.env.gcm_api_key, payload: payload }) do
              post :send_video_received, params
            end
          end
        end

        it { expect(response).to have_http_status(:success) }
        it { expect(JSON.parse(response.body)).to eq('status' => '200') }
      end
    end

    context 'iOS' do
      let(:receiver) { create(:ios_user) }

      specify 'expects GenericPushNotification to receive :send_notification' do
        expect(GenericPushNotification).to receive(:send_notification)
        authenticate_with_http_digest(user.mkey, user.auth) do
          post :send_video_received, params
        end
      end

      context 'response' do
        before do
          authenticate_with_http_digest(user.mkey, user.auth) do
            post :send_video_received, params
          end
        end

        it { expect(response).to have_http_status(:success) }
        it { expect(JSON.parse(response.body)).to eq('status' => '200') }
      end
    end
  end

  describe 'POST #send_video_status_update' do
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
                   host: 'test.host' } }
    end

    it 'expects any instance of PushUser receives :send_notification with valid attributes' do
      expect_any_instance_of(PushUser).to receive(:send_notification).with(attributes)
      authenticate_with_http_digest(user.mkey, user.auth) do
        post :send_video_status_update, params
      end
    end

    context 'target_mkey not given' do
      let(:params) { {} }
      before do
        authenticate_with_http_digest(user.mkey, user.auth) do
          post :send_video_status_update, params
        end
      end
      it 'returns http not_found' do
        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'event notification' do
      let(:event_params) do
        { initiator: 'user',
          initiator_id: user.mkey,
          target: 'video',
          target_id: video_filename,
          data: {
            sender_id: params[:target_mkey],
            receiver_id: params[:to_mkey],
            video_filename: video_filename,
            video_id: video_id
          },
          raw_params: params.stringify_keys }
      end

      subject do
        allow(GenericPushNotification).to receive(:send_notification)
        authenticate_with_http_digest(user.mkey, user.auth) do
          post :send_video_status_update, params
        end
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
        authenticate_with_http_digest(user.mkey, user.auth) do
          VCR.use_cassette('gcm_send_with_error', erb: {
                             key: Figaro.env.gcm_api_key, payload: payload }) do
            post :send_video_status_update, params
          end
        end
      end

      context 'response' do
        before do
          authenticate_with_http_digest(user.mkey, user.auth) do
            VCR.use_cassette('gcm_send_with_error', erb: {
                               key: Figaro.env.gcm_api_key, payload: payload }) do
              post :send_video_status_update, params
            end
          end
        end
        it { expect(response).to have_http_status(:success) }
        it { expect(JSON.parse(response.body)).to eq('status' => '200') }
      end
    end

    context 'iOS' do
      let(:sender) { create(:ios_user) }

      specify 'expects GenericPushNotification to receive :send_notification' do
        expect(GenericPushNotification).to receive(:send_notification)
        authenticate_with_http_digest(user.mkey, user.auth) do
          post :send_video_status_update, params
        end
      end

      context 'response' do
        before do
          authenticate_with_http_digest(user.mkey, user.auth) do
            post :send_video_status_update, params
          end
        end
        it { expect(response).to have_http_status(:success) }
        it { expect(JSON.parse(response.body)).to eq('status' => '200') }
      end
    end
  end
end
