class StatusController < ApplicationController

  def heartbeat
    render json: {version: APP_CONFIG[:version]}
  end
end