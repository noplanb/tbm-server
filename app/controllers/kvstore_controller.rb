class KvstoreController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def set
    Kvstore.create_or_update(kvstore_params)
    render :text => "ok"
  end
  
  def get
    render :json => get_kvs.first
  end
  
  def get_all
    render :json => get_kvs
  end
  
  def delete
    kvs = get_kvs
    logger.info "deleting #{kvs.length} kvs"
    kvs.each{|kv| kv.destroy}
    render :text => "ok"
  end
  
  private
  
  def get_kvs
      return Kvstore.where("key1 = ? and key2 is null", params[:key1]) if params[:key2].blank?
      Kvstore.where("key1 = ? and key2 = ?", params[:key1], params[:key2])
  end
  
  def kvstore_params
    params.permit(:key1, :key2, :value)
  end

end