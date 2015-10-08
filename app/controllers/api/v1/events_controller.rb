class Api::V1::EventsController < ActionController::Base
  def create
    if service.do
      head :ok
    else
      render json: { errors: service.errors }, status: :unprocessable_entity
    end
  end

  private

  def service
    @event_service ||= HandleOutgoingVideo.new params.require('Records')
  end
end
