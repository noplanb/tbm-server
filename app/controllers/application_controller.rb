class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  
  # ==================
  # = Before filters =
  # ==================
  def verify_user
    set_user
    if @user.blank? || @user.auth != params[:auth] 
      render nothing: true, status: :unauthorized
      return false
    end
    true
  end
  
  def set_user
    @user = User.find_by_mkey(params[:mkey])
  end
  

end
