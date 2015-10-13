class Api::V1::EventsController < ActionController::Base
  include HandleWithManager

  before_action :log_params

  def create
    s3_params = params.require('Records')
    handle_with_manager HandleOutgoingVideo.new(s3_params) do
      EventDispatcher.resend_s3_event 'Records' => s3_params
    end
  end

  private

  def log_params
    WriteLog.info self, "Request params: #{params.inspect}"
  end
end
