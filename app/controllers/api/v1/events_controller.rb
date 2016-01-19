class Api::V1::EventsController < ActionController::Base
  before_action :log_params

  def create
    manager = HandleOutgoingVideo.new params['Records']
    HandleOutgoingVideo::StatusNotifier.new(manager).log_messages manager.do ? :success : :failure
    head :ok
  end

  private

  def log_params
    WriteLog.info self, "Request params: #{params.inspect}"
  end
end
