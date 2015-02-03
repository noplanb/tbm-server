class KvstoreAdminController < ApplicationController
  http_basic_authenticate_with :name => "admin", :password => "Statorama1"
  
  def index
  end
  
  def delete_all
    Kvstore.all.each{|k| k.destroy}
    redirect_to action: :index
  end
  
end
