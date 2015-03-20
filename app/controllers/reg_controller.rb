class RegController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate, except: [:reg, :debug_get_user]

  def reg
    raw_phone = params[:mobile_number]

    unless GlobalPhone.validate raw_phone
      Rails.logger.error('reg/reg: bad_phone')
      return render json: { status: 'failure', title: 'Bad Phone', msg: 'Please enter a valid country code and phone number' }
    end

    if params[:device_platform].blank?
      Rails.logger.error("ERROR: reg/reg: no device_platform: #{params.inspect}")
      return render json: { status: 'failure', title: 'No Platform', msg: 'No device_platform' }
    end

    params[:mobile_number] = GlobalPhone.normalize raw_phone

    user = User.find_by_mobile_number(params[:mobile_number]) || User.create(user_params)

    unless user
      Rails.logger.error("ERROR: reg/reg: could not find or create user: #{params.inspect}")
      return render json: { status: 'failure', title: "Can't Add", msg: 'Unable to create user' }
    end

    opts = case SmsManager.new(user).send_verification_sms
    when :ok
      { status: 'success', auth: user.auth, mkey: user.mkey }
    when :invalid_mobile_number
      { status: 'failure', title: 'Bad mobile number', msg: 'Please enter a valid country code and mobile number' }
    else
      { status: 'failure', title: 'Sorry!', msg:  'We encountered a problem on our end. We will fix shortly. Please try again later.' }
    end
    render json: opts
  end

  def debug_get_user
    mobile = params[:country_code].blank? ? params[:mobile_number] : "+#{params[:country_code]}#{params[:mobile_number]}"
    user = User.where(mobile_number: mobile).first || not_found
    render json: { status: 'success' }.merge(user.only_app_attrs_for_user)
  end

  def verify_code
    if @user && @user.passes_verification(params[:verification_code])

      if params[:device_platform].blank?
        Rails.logger.error("ERROR: reg/reg: no device_platform: #{params.inspect}")
        return render json: { status: 'failure', title: 'No Platform', msg: 'No device_platform' }
      end

      # Update first and last here in case user decided to change his name to correct it
      # or something when logging in again.
      @user.update_attributes first_name: params[:first_name], last_name: params[:last_name], status: :verified, device_platform: params[:device_platform]
      render json: { status: 'success' }.merge(@user.only_app_attrs_for_user)
    else
      render json: { status: 'failure' }
    end
  end

  def get_friends
    if @user
      render json: @user.connected_users.map { |u| u.only_app_attrs_for_friend_with_ckey(@user) }
    else
      render json: []
    end
  end

  private

  def user_params
    params.permit(:first_name, :last_name, :mobile_number, :device_platform, :status, :verification_code)
  end
end
