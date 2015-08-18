class ConnectionController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate

  def set_visibility
    service = Connection::SetVisibility.new params, current_user

    respond_to do |format|
      if service.do
        format.json { head :ok }
      else
        format.json { render json: service.errors, status: :unprocessable_entity }
      end
    end
  end
end
