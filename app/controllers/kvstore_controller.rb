class KvstoreController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate, only: [:received_videos, :received_messages, :received_texts, :video_status]

  def set
    Kvstore.create_or_update(kvstore_params)
    render json: { status: '200' }
  end

  # TODO: delete methods below?

  def get
    render json: get_kvs.first
  end

  def get_all
    kvs = get_kvs
    logger.info "#{params[:key1]} count = #{kvs.length}"
    render json: get_kvs
  end

  def delete
    kvs = get_kvs
    logger.info "deleting #{kvs.length} kvs"
    kvs.destroy_all
    render json: { status: '200' }
  end

  def received_videos
    render json: current_user.received_videos
  end

  def received_messages
    render json: current_user.received_messages
  end

  def received_texts
    render json: current_user.received_texts
  end

  def video_status
    render json: current_user.video_status
  end

  private

  def get_kvs
    return Kvstore.where('key1 = ?', params[:key1]) if params[:key2].blank?
    Kvstore.where('key1 = ? and key2 = ?', params[:key1], params[:key2])
  end

  def kvstore_params
    params.permit(:key1, :key2, :value)
  end
end
