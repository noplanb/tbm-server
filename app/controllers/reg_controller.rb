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
              :jill => User.find_by_first_name("Jill"),
              :moto => User.find_by_first_name("MotoG"),
              :iphone5c => User.find_by_first_name("Iphone5c"),
              :nexus_red => User.find_by_first_name("NexusRed"),
              :nexus_black => User.find_by_first_name("NexusBlack"),
              :burns => User.find_by_first_name("Burns")}
    
    u = User.find id
    case u.first_name
    when "Sani"
      return [users[:farhad], users[:kon], users[:jill], users[:moto], users[:iphone5c], users[:nexus_red], users[:nexus_black],  users[:burns]]
    when "Farhad"
      return [users[:kon], users[:sani], users[:moto], users[:iphone5c], users[:nexus_red], users[:nexus_black]]
    when "Konstantin"
      return [users[:farhad], users[:sani], users[:moto], users[:iphone5c], users[:nexus_red], users[:nexus_black]]
    when "Jill"
      return [users[:sani]]
    when "Burns"
      return [users[:sani]]
    when "MotoG"
      return [users[:sani], users[:iphone5c], users[:nexus_red], users[:nexus_black], users[:farhad], users[:kon]]
    when "Iphone5c"
      return [users[:sani], users[:moto], users[:nexus_red], users[:nexus_black], users[:farhad], users[:kon]]
    when "NexusRed"
      return [users[:sani], users[:iphone5c], users[:moto], users[:nexus_black], users[:farhad], users[:kon]]
    when "NexusBlack"
      return [users[:sani], users[:iphone5c], users[:nexus_red], users[:moto], users[:farhad], users[:kon]]
    end
  end
  
  def only_app_attrs(a)
    a.map{ |u| {:id => u.id.to_s, :first_name => u.first_name, :last_name => u.last_name} }
  end
  
  def push_token
    user = User.find(params[:user_id])
    user.update_attribute(:push_token, params[:push_token])
    
    if params[:device_platform]
      user.update_attribute(:device_platform, params[:device_platform])
    end
    
    render :json => {"status" => 200}
  end
  
  def echo
    render :text => params.inspect
  end
  
end
