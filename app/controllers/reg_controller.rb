class RegController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate, except: [:reg, :debug_get_user]
  before_action :validate_mobile_number, only: [:reg]
  before_action :validate_device_platform, only: [:reg, :verify_code]
  before_action :find_or_create_user, only: [:reg]

  def reg
    method = case params[:via]
             when 'sms'
               :send_verification_sms
             when 'call'
               :make_verification_call
             else
               :send_code
             end
    opts = case VerificationCodeSender.new(@user, params).send(method)
           when :ok
             { status: 'success',
               auth: @user.auth,
               mkey: @user.mkey }
           when :invalid_mobile_number
             { status: 'failure',
               title: 'Bad mobile number',
               msg: 'Please enter a valid country code and mobile number' }
           else
             { status: 'failure',
               title: 'Sorry!',
               msg:  'We encountered a problem on our end. We will fix shortly. Please try again later.' }
           end
    render json: opts
  end

  def debug_get_user
    mobile = params[:country_code].blank? ? params[:mobile_number] : "+#{params[:country_code]}#{params[:mobile_number]}"
    user = User.where(mobile_number: mobile).first || not_found
    render json: { status: 'success' }.merge(user.only_app_attrs_for_user)
  end

  def verify_code
    if @user && @user.passes_verification(params.delete(:verification_code))
      # Update first and last here in case user decided to change his name to correct it
      # or something when logging in again.
      @user.attributes = user_params
      if @user.may_verify?
        @user.verify!
      else
        @user.save
      end
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

  def validate_mobile_number
    unless GlobalPhone.validate params[:mobile_number]
      Rails.logger.error('reg/reg: bad_phone')
      render json: { status: 'failure',
                     title: 'Bad Phone',
                     msg: 'Please enter a valid country code and phone number' }
    end
  end

  def validate_device_platform
    if params[:device_platform].blank?
      Rails.logger.error("ERROR: reg/reg: no device_platform: #{params.inspect}")
      render json: { status: 'failure',
                     title: 'No Platform',
                     msg: 'No device_platform' }
    end
  end

  def find_or_create_user
    @user = User.find_by_raw_mobile_number(params[:mobile_number]) || User.create(user_params)
    unless @user
      Rails.logger.error("ERROR: reg/reg: could not find or create user: #{params.inspect}")
      render json: { status: 'failure',
                     title: "Can't Add",
                     msg: 'Unable to create user' }
    end
  end
end
