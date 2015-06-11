require 'rails_helper'

RSpec.describe KvstoreController, type: :controller do
  let(:video_id) { '1426622544176' }
  let(:connection) { create(:established_connection) }
  let(:sender) { connection.creator }
  let(:receiver) { connection.target }

  describe 'POST #set' do
    let(:params) do
      { key1: Kvstore.generate_id_key(sender, receiver, connection),
        key2: video_id, value: { 'videoId' => video_id }.to_json }
    end

    specify do
      expect(Kvstore).to receive(:create_or_update).with(params)
      post :set, params
    end

    it 'returns http success' do
      post :set, params
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #delete' do
    it 'returns http success' do
      get :delete
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #received_videos' do
    context 'when authenticated' do
      let(:user) { create(:user) }

      specify do
        authenticate_with_http_digest(user.mkey, user.auth) do
          get :received_videos
        end
        is_expected.to respond_with(:success)
      end

      specify do
        expect(Kvstore).to receive(:received_videos).with(user)
        authenticate_with_http_digest(user.mkey, user.auth) do
          get :received_videos
        end
      end
    end

    context 'when not authenticated' do
      before { get :received_videos }
      it { is_expected.to respond_with(:unauthorized) }
    end
  end
end
