require 'rails_helper'

RSpec.describe Api::V1::MessagesController, type: :controller do
  include_context 'user authentication'
  include_context 'user prepared messages'

  let(:user) { create(:user) }

  [
    { method: 'get', action: 'index' }
  ].each do |desc|
    describe "#{desc[:method].upcase} ##{desc[:action]}" do
      context 'when authorized' do
        it do
          authenticate_user { send(desc[:method], desc[:action]) }
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when not authorized' do
        it do
          send(desc[:method], desc[:action])
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
