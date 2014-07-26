class Kvstore < ActiveRecord::Base
  
  def self.create_or_update(params)
    kv = find_by_key(params[:key])
    if kv
      kv.update_attribute(:value, params[:value])
    else
      create!(key: params[:key], value: params[:value])
    end
  end
  
end
