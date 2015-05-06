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
end
