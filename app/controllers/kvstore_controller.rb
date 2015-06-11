class KvstoreController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate, only: [:received_videos, :video_status]

  def set
    Kvstore.create_or_update(kvstore_params)
    render json: { status: '200' }
  end

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

  # ================
  # = Load testing =
  # ================
  # These dont require auth rememeber to remove them from routes after testing.
  def load_test_read
    get_all
  end

  def load_test_write
    set
  end

  def received_videos
    render json: Kvstore.received_videos(current_user)
  end

  def video_status
    render json: Kvstore.video_status(current_user)
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
