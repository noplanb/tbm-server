class Api::V1::EventsController < ActionController::Base
  include HandleWithManager

  before_action :resend_s3_event, :log_params

  def create
    handle_with_manager HandleOutgoingVideo.new(params.require('Records'))
  end

  private

  def resend_s3_event
    EventDispatcher.resend_s3_event 'Records' => params.require('Records')
  end

  def log_params
    WriteLog.info self, "Request params: #{params.inspect}"
  end
end
