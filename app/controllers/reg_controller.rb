class RegController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  
  def get_friends
    if user = params[:mkey] && User.find_by_mkey(params[:mkey])
      render :json => only_app_attrs(user.connected_users)
    else
      render :json => []
    end
  end
  
  def get_user
    if user = params[:mobile_number] && User.find_by_mobile_number(params[:mobile_number])
      render :json => only_app_attrs([user]).first
    else
      render :json => {}
    end
  end
  
  def echo
    render :text => params.inspect
  end
  
  # deprecated
  # def user_list
  #   all = User.all
  #   all.shift
  #   render :json => only_app_attrs(all)
  # end
  
  private
  
  def only_app_attrs(a)
    a.map{ |u| {:id => u.id.to_s, :auth => u.auth, :mkey => u.mkey, :first_name => u.first_name, :last_name => u.last_name} }
  end
  
end
