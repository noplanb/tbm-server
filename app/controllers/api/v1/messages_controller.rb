class Api::V1::MessagesController < ApplicationController
  before_action :authenticate

  def index
    render json: Kvstore::GetMessages.new(user: current_user).call
  end

  def create
    Kvstore::AddMessage.new
  end

  def update
    Kvstore::UpdateMessageStatus.new
  end

  def delete
    Kvstore::UpdateMessageStatus.new
  end
end
