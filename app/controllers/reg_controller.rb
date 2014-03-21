class RegController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def user_list
    all = User.all
    all.shift
    render :json => only_app_attrs(all)
  end
  
  def register
    friends = get_friends params[:id]
    render :json => only_app_attrs(friends)
  end
  
  def get_friends(id)
    users = { :sani => User.find_by_first_name("Sani"),
              :farhad => User.find_by_first_name("Farhad"),
              :kon => User.find_by_first_name("Konstantin"),
              :jill => User.find_by_first_name("Jill")}
    
    u = User.find id
    case u.first_name
    when "Sani"
      return [users[:farhad], users[:kon], users[:jill]]
    when "Farhad"
      return [users[:kon], users[:sani]]
    when "Konstantin"
      return [users[:farhad], users[:sani]]
    when "Jill"
      return [users[:sani]]
    end
  end
  
  def only_app_attrs(a)
    a.map{ |u| {:id => u.id.to_s, :first_name => u.first_name, :last_name => u.last_name} }
  end
  
  def push_token
    user = User.find(params[:user_id])
    user.update_attribute(:push_token, params[:push_token])
    render :text => "ok"
  end
  
  def echo
    render :text => params.inspect
  end
  
end
