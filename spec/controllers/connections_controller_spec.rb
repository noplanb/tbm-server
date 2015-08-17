require 'rails_helper'

RSpec.describe ConnectionsController, type: :controller do
  before { authenticate_with_http_basic }

  describe 'POST #set_visibility' do
    before { post :set_visibility, format: :json }

    it 'has a 200 status code' do
      expect(response).to have_http_status 200
    end
  end
end
