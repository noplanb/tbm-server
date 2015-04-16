class KvstoreAdminController < AdminController
  http_basic_authenticate_with name: Figaro.env.http_basic_username, password: Figaro.env.http_basic_password

  def index
    @kvstores = Kvstore.all
  end

  def delete_all
    Kvstore.destroy_all
    redirect_to action: :index
  end
end
