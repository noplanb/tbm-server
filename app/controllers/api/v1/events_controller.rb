class Api::V1::EventsController < ActionController::Base
  include HandleWithManager

  before_action :log_params

  def create
    handle_with_manager HandleOutgoingVideo.new(params['Records']) do
      EventDispatcher.resend_s3_event 'Records' => params['Records']
    end
  end

  private

  def log_params
    WriteLog.info self, "Request params: #{params.inspect}"
  end
end
