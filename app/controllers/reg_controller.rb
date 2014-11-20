class RegController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :verify_user, except: [:reg, :debug_get_user]
  
  def reg  
    raw_phone = params[:mobile_number]
    
    if !GlobalPhone.validate raw_phone
      Rails.logger.error("reg/reg: bad_phone")
      render json: {status:"failure", title:"Bad Phone", msg:"Please enter a valid country code and phone number"}
      return
    end
    
    if (params[:device_platform].blank?)
      Rails.logger.error("ERROR: reg/reg: no device_platform: #{params.inspect}")
      render json: {status:"failure", title:"No Platform", msg:"No device_platform"}
      return
    end
    
    params[:mobile_number] = GlobalPhone.normalize raw_phone
       
    user = User.find_by_mobile_number(params[:mobile_number]) || User.create(user_params)
    
    if (!user)
      Rails.logger.error("ERROR: reg/reg: could not find or create user: #{params.inspect}")
      render json: {status:"failure", title:"Can't Add", msg:"Unable to create user"}
      return
    end
    
    render json: {status:"success", auth:user.auth, mkey:user.mkey}
    SmsManager.new.send_verification_sms(user)
  end
  
  def debug_get_user
    user = User.find_by_mobile_number(params[:mobile_number]) || User.first
    render json: {status: "success"}.merge(user.only_app_attrs_for_user)
  end
  
  def verify_code
    if @user && @user.passes_verification(params[:verification_code])
      # Update first and last here in case user decided to change his name to correct it
      # or something when logging in again.
      @user.update_attributes first_name: params[:first_name], last_name: params[:last_name], status: :verified
      render json: {status: "success"}.merge(@user.only_app_attrs_for_user)
    else
      render json: {status: "failure"}
    end
  end
  
  def get_friends
    if @user
      render json: @user.connected_users.map{|u| u.only_app_attrs_for_friend}
    else
      render json: []
    end
  end
  
  private
  
  def user_params
    params.permit(:first_name, :last_name, :mobile_number, :device_platform, :status)
  end
end
