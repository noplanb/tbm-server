require 'rails_helper'

RSpec.describe KvstoreController, type: :controller do
  let(:user) { create(:user) }
  let(:message_id) { '1426622544176' }
  let(:connection) { create(:established_connection) }
  let(:sender) { connection.creator }
  let(:receiver) { connection.target }

  def authenticate_user
    authenticate_with_http_digest(user.mkey, user.auth) { yield }
  end

  describe 'POST #set' do
    context 'video message' do
      let(:params) do
        { key1: Kvstore.generate_id_key(sender, receiver, connection),
          key2: message_id, value: { 'videoId' => message_id }.to_json }
      end

      it do
        expect(Kvstore).to receive(:create_or_update).with(params)
        authenticate_user { post :set, params }
      end

      it 'returns http success' do
        authenticate_user { post :set, params }
        expect(response).to have_http_status(:success)
      end

      context 'when not authenticated' do
        before { post :set, params }

        it { is_expected.to respond_with(:unauthorized) }
      end
    end

    context 'text message' do
      let(:params) do
        { key1: Kvstore.generate_id_key(sender, receiver, connection), key2: message_id,
          value: { 'messageId' => message_id, 'type' => 'text', 'body' => 'Hello World!' }.to_json }
      end

      it do
        expect(Kvstore).to receive(:create_or_update).with(params)
        authenticate_user { post :set, params }
      end

      it 'returns http success' do
        authenticate_user { post :set, params }
        expect(response).to have_http_status(:success)
      end

      context 'when not authenticated' do
        before { post :set, params }

        it { is_expected.to respond_with(:unauthorized) }
      end
    end
  end

  describe 'GET #delete' do
    it 'returns http success' do
      authenticate_user { get :delete }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #received_videos' do
    context 'when authenticated' do
      it do
        authenticate_user { get :received_videos }
        is_expected.to respond_with(:success)
      end

      it do
        expect_any_instance_of(User).to receive(:received_videos)
        authenticate_user { get :received_videos }
      end
    end

    context 'when not authenticated' do
      before { get :received_videos }

      it { is_expected.to respond_with(:unauthorized) }
    end
  end

  describe 'GET #received_texts' do
    context 'when authenticated' do
      let(:user) { create(:user) }

      it do
        authenticate_user { get :received_texts }
        is_expected.to respond_with(:success)
      end

      it do
        expect_any_instance_of(User).to receive(:received_texts)
        authenticate_user { get :received_texts }
      end
    end

    context 'when not authenticated' do
      before { get :received_videos }

      it { is_expected.to respond_with(:unauthorized) }
    end
  end

  describe 'GET #video_status' do
    context 'when authenticated' do
      let(:user) { create(:user) }

      it do
        authenticate_user { get :video_status }
        is_expected.to respond_with(:success)
      end

      it do
        expect_any_instance_of(User).to receive(:video_status)
        authenticate_user { get :video_status }
      end
    end

    context 'when not authenticated' do
      before { get :video_status }

      it { is_expected.to respond_with(:unauthorized) }
    end
  end
end
