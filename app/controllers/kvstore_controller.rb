class KvstoreController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate
  before_action :set_service, only: %i(received_videos video_status messages)

  def set
    Kvstore.create_or_update(kvstore_params)
    render json: { status: '200' }
  end

  def get
    render json: get_kvs.first
  end

  def get_all
    kvs = get_kvs
    logger.info("#{params[:key1]} count = #{kvs.length}")
    render json: get_kvs
  end

  def delete
    kvs = get_kvs
    logger.info("deleting #{kvs.length} kvs")
    kvs.destroy_all
    render json: { status: '200' }
  end

  #
  # new API
  #

  def messages
    render json: @service.call(filter: params[:filter])
  end

  #
  # legacy API
  #

  def received_videos
    render json: @service.legacy(:received_videos)
  end

  def video_status
    render json: @service.legacy(:video_status)
  end

  private

  def get_kvs
    return Kvstore.where('key1 = ?', params[:key1]) if params[:key2].blank?
    Kvstore.where('key1 = ? and key2 = ?', params[:key1], params[:key2])
  end

  def set_service
    @service = Kvstore::GetMessages.new(user: current_user)
  end

  def kvstore_params
    params.permit(:key1, :key2, :value)
  end
end
