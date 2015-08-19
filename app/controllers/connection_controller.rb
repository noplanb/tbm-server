class ConnectionController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate

  def set_visibility
    service = Connection::SetVisibility.new params, current_user

    if service.do
      render json: { status: 'success' }
    else
      render json: { status: 'failure', errors: service.errors }
    end
  end
end
