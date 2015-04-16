class MechanicalTurkController < AdminController
  def index
    if params[:query].present?
      @users = User.search(params[:query])
    end
  end
end
