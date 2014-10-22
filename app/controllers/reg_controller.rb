class RegController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def reg
    user = User.find_by_mobile_number(params[:user][:mobile_number])
    if user
      user.update_attributes user_params
    else
      user = User.create user_params
    end
    render :json => user.only_app_attrs_for_user
  end
  
  def get_friends
    if user = params[:auth] && User.find_by_auth(params[:auth])
      render :json => user.connected_users.map{|u| u.only_app_attrs_for_friend}
    else
      render :json => []
    end
  end
  
  def get_user
    if user = params[:mobile_number] && User.find_by_mobile_number(params[:mobile_number])
      render :json => user.only_app_attrs_for_user
    else
      render :json => {}
    end
  end
  
  def echo
    render :text => params.inspect
  end
  
  private
  
  def user_params
    params.require(:user).permit(:first_name, :last_name, :mobile_number, :device_platform)
  end
end
