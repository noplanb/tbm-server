class StatusController < ApplicationController

  def heartbeat
    render json: {version: Settings.version}
  end
end