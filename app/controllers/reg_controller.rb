class RegController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def reg
    user = User.find_by_mobile_number(params[:user][:mobile_number])
    if user
      user.update_attributes user_params
    else
      user = User.create user_params
    end
    render :json => only_app_attrs(user.attributes.symbolize_keys)
  end
  
  def get_friends
    if user = params[:mkey] && User.find_by_mkey(params[:mkey])
      render :json => user.connected_users_attributes_with_connection_status.map{|f| only_app_attrs(f)}
    else
      render :json => []
    end
  end
  
  def get_user
    if user = params[:mobile_number] && User.find_by_mobile_number(params[:mobile_number])
      render :json => only_app_attrs(user.attributes.symbolize_keys)
    else
      render :json => {}
    end
  end
  
  def echo
    render :text => params.inspect
  end
  
  private
  
  def only_app_attrs(u)
    r = u.slice(:id, :auth, :mkey, :first_name, :last_name, :mobile_number, :device_platform, :connection_status, :is_connection_creator)
    r[:id] = r[:id].to_s
    r
  end
  
  def user_params
    params.require(:user).permit(:first_name, :last_name, :mobile_number, :device_platform)
  end
end
