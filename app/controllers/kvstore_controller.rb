class KvstoreController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def set
    Kvstore.create_or_update(kvstore_params)
    render :text => "ok"
  end
  
  def get
    kv = Kvstore.find_by_key(params[:key])
    render :text => kv && kv.value
  end
  
  private
  
  def kvstore_params
    params.permit(:key, :value)
  end

end