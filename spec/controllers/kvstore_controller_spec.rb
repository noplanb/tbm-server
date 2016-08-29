require 'rails_helper'

RSpec.describe KvstoreController, type: :controller do
  include_context 'user authentication'

  let(:user) { create(:user) }
  let(:message_id) { '1426622544176' }
  let(:connection) { create(:established_connection) }
  let(:sender) { connection.creator }
  let(:receiver) { connection.target }

  describe 'POST #set' do
    let(:video_message_params) do
      { key1: Kvstore.generate_id_key(sender, receiver, connection),
        key2: message_id, value: { 'videoId' => message_id }.to_json }
    end
    let(:text_message_params) do
      { key1: Kvstore.generate_id_key(sender, receiver, connection), key2: message_id,
        value: { 'messageId' => message_id, 'type' => 'text', 'body' => 'Hello World!' }.to_json }
    end

    [
      { context: 'video message', params_key: :video_message_params },
      { context: 'text message',  params_key: :text_message_params }
    ].each do |data|
      context data[:context] do
        let(:params) { send(data[:params_key]) }

        context 'when authenticated' do
          it do
            expect(Kvstore).to receive(:create_or_update).with(params)
            authenticate_user { post :set, params }
          end

          it 'returns http success' do
            authenticate_user { post :set, params }
            expect(response).to have_http_status(:success)
          end
        end

        context 'when not authenticated' do
          it 'returns http unauthorized' do
            post :set, params
            is_expected.to respond_with(:unauthorized)
          end
        end
      end
    end
  end

  describe 'GET #delete' do
    it 'returns http success' do
      authenticate_user { get :delete }
      expect(response).to have_http_status(:success)
    end
  end

  %i(received_videos video_status).each do |action|
    describe "GET ##{action}" do
      it 'responds with success when authenticated' do
        authenticate_user { get action }
        is_expected.to respond_with(:success)
      end

      it 'responds with unauthorized when not authenticated' do
        get action
        is_expected.to respond_with(:unauthorized)
      end
    end
  end
end
