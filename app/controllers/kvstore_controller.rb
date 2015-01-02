class KvstoreController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def set
    Kvstore.create_or_update(kvstore_params)
    render :json => {status: "200"}
  end
  
  def get
    render :json => get_kvs.first
  end
  
  def get_all
    kvs = get_kvs
    logger.info "#{params[:key1]} count = #{kvs.length}"
    render :json => get_kvs
  end
  
  def delete
    kvs = get_kvs
    logger.info "deleting #{kvs.length} kvs"
    kvs.each{|kv| kv.destroy}
    render :json => {status: "200"}
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
  
  private
  
  def get_kvs
      return Kvstore.where("key1 = ?", params[:key1]) if params[:key2].blank?
      Kvstore.where("key1 = ? and key2 = ?", params[:key1], params[:key2])
  end
  
  def kvstore_params
    params.permit(:key1, :key2, :value)
  end

end