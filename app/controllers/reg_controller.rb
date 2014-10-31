class RegController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :verify_user, except: [:reg]
  
  def reg    
    raw_phone = params[:mobile_number]
    
    if !GlobalPhone.validate raw_phone
      Rails.Logger.info("reg/reg: bad_phone")
      render :json => {status:"failure", title:"Bad Phone", msg:"Please enter a valid country code and phone number"}
      return
    end
    
    params[:mobile_number] = GlobalPhone.normalize raw_phone
       
    user = User.find_by_mobile_number(params[:mobile_number]) || User.create(user_params.merge(status: :initialized))
    render :json => {status:"success", auth:user.auth, mkey:user.mkey}
    SmsManager.new.send_verification_sms(user)
  end
  
  def verify_code
    if @user && @user.passes_verification(params[:verification_code])
      @user.update_attributes user_params.merge(status: :verified)
      render :json => {status: "success"}.merge(@user.only_app_attrs_for_user)
    else
      render :json => {status: "failure"}
    end
  end
  
  def get_friends
    if @user
      render :json => @user.connected_users.map{|u| u.only_app_attrs_for_friend}
    else
      render :json => []
    end
  end
  
  private
  
  def verify_user
    set_user
    return false if @user.blank? || @user.auth != params[:auth] 
    true
  end
  
  def set_user
    @user = User.find_by_mkey(params[:mkey])
  end
  
  def user_params
    params.permit(:first_name, :last_name, :mobile_number, :device_platform, :status)
  end
end
