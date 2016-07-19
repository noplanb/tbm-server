require 'rails_helper'

RSpec.describe Api::V1::MessagesController, type: :controller do
  include_context 'user authentication'
  include_context 'user prepared messages'

  let(:user) { create(:user) }
  let(:params_id) { { id: message_22 } }
  let(:params_id_r) { { id: message_21r } }
  let(:params_receiver_mkey) { { receiver_mkey: friend_2.mkey } }
  let(:params_sender_mkey) { { sender_mkey: friend_2.mkey } }
  let(:params_type) { { type: 'text' } }
  let(:params_status) { { status: 'uploaded' } }

  [
    { method: 'get', action: 'index' },
    { method: 'get', action: 'show', params: %w(id) },
    { method: 'post', action: 'create', params: %w(id receiver_mkey type) },
    { method: 'patch', action: 'update', params: %w(id_r sender_mkey type status) },
    { method: 'delete', action: 'destroy', params: %w(id) }
  ].each do |desc|
    describe "#{desc[:method].upcase} ##{desc[:action]}" do
      let(:params) do
        (desc[:params] || []).each_with_object({}) do |attr, memo|
          memo.merge!(send("params_#{attr}"))
        end
      end

      context 'when authorized' do
        it do
          authenticate_user { send(desc[:method], desc[:action], params) }
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when not authorized' do
        it do
          send(desc[:method], desc[:action], params)
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
