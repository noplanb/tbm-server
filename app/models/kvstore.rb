class Kvstore < ActiveRecord::Base
  def self.create_or_update(params)
    if params[:key2].blank?
      kvs = where('key1 = ? and key2 is null', params[:key1])
    else
      kvs = where('key1 = ? and key2 = ?', params[:key1], params[:key2])
    end

    if !kvs.blank?
      kvs.first.update_attribute(:value, params[:value])
    else
      create(key1: params[:key1], key2: params[:key2], value: params[:value])
    end
  end
end
