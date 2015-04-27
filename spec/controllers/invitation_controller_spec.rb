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
    let(:invitee) { User.find_by_raw_mobile_number(params[:mobile_number]) }

    context 'when invitee not exists with given mobile_number' do
      it 'returns http success' do
        authenticate_with_http_digest(user.mkey, user.auth) do
          get :invite, params
        end
        expect(response).to have_http_status(:success)
      end

      context 'invitee status' do
        specify do
          authenticate_with_http_digest(user.mkey, user.auth) do
            get :invite, params
          end
          expect(invitee.status).to eq(:initialized)
        end
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

      context 'invitee status' do
        specify do
          authenticate_with_http_digest(user.mkey, user.auth) do
            get :invite, params
          end
          expect(invitee.status).to eq(:initialized)
        end
      end
    end
  end
end
