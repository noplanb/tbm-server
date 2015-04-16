require 'rails_helper'

RSpec.describe MechanicalTurkController, type: :controller do
  before { authenticate_with_http_basic }

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
