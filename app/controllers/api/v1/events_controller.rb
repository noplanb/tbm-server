class Api::V1::EventsController < ActionController::Base
  before_action :resend_s3_event, :log_params

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

  def resend_s3_event
    EventDispatcher.resend_s3_event 'Records' => params.require('Records')
  end

  def log_params
    Rails.logger.tagged(self.class.name) { Rails.logger.info "Request params: #{params.inspect}" }
  end
end
