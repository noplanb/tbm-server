class KvstoreAdminController < AdminController
  def index
    @kvstores = Kvstore.all.page(params[:page])
  end

  def delete_all
    Kvstore.destroy_all
    redirect_to action: :index
  end
end
