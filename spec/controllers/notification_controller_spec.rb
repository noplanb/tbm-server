require 'rails_helper'

RSpec.describe NotificationController, type: :controller do
  let(:video_id) { (Time.now.to_f * 1000).to_i.to_s }
  let(:user) { create(:user) }
  let(:target) do
    create(:push_user,
           mkey: user.mkey,
           device_platform: user.device_platform)
  end
  let(:push_user_params) do
    { mkey: user.mkey,
      push_token: 'push_token',
      device_platform: user.device_platform,
      device_build: :dev }
  end

  describe 'POST #set_push_token' do
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
    let(:params) do
      push_user_params.merge(from_mkey: user.mkey,
                             target_mkey: target.mkey,
                             video_id: video_id)
    end

    context 'Android' do
      let(:user) { create(:android_user) }
      let(:payload) do
        GcmServer.make_payload(
          params[:push_token],
          type: 'video_received',
          from_mkey: params[:from_mkey],
          video_id: params[:video_id])
      end
      before do
        authenticate_with_http_digest(user.mkey, user.auth) do
          VCR.use_cassette('gcm_send_with_error', erb: { key: Figaro.env.gcm_api_key, payload: payload }) do
            post :send_video_received, params
          end
        end
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'iOS' do
      let(:user) { create(:ios_user) }
      before do
        authenticate_with_http_digest(user.mkey, user.auth) do
          post :send_video_received, params
        end
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST #send_video_status_update' do
    let(:params) do
      push_user_params.merge(to_mkey: user.mkey,
                             target_mkey: target.mkey,
                             video_id: video_id,
                             status: 'viewed')
    end

    context 'Android' do
      let(:user) { create(:android_user) }
      let(:payload) do
        GcmServer.make_payload(
          params[:push_token],
          type: 'video_status_update',
          to_mkey: params[:to_mkey],
          status: params[:status],
          video_id: params[:video_id])
      end
      before do
        authenticate_with_http_digest(user.mkey, user.auth) do
          VCR.use_cassette('gcm_send_with_error', erb: { key: Figaro.env.gcm_api_key, payload: payload }) do
            post :send_video_status_update, params
          end
        end
      end
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'iOS' do
      let(:user) { create(:ios_user) }
      before do
        authenticate_with_http_digest(user.mkey, user.auth) do
          post :send_video_status_update, params
        end
      end
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end
  end
end
