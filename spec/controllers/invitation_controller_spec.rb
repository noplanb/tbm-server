require 'rails_helper'

RSpec.describe InvitationController, type: :controller do
  describe 'GET #invite' do
    let(:params) do
      {
        first_name: 'John',
        last_name: 'Appleseed',
        mobile_number: '+1 650-111-0000'
      }
    end
    let(:user) { create(:user) }

    context 'when invitee not exists with given mobile_number' do
      it 'returns http success' do
        authenticate_with_http_digest(user.mkey, user.auth) do
          get :invite, params
        end
        expect(response).to have_http_status(:success)
      end
    end

    context 'when invitee already exists with given mobile_number' do
      let!(:invitee) { create(:user, params) }

      it 'returns http success' do
        authenticate_with_http_digest(user.mkey, user.auth) do
          get :invite, params
        end
        expect(response).to have_http_status(:success)
      end
    end
  end
end
