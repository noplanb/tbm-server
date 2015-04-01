class InvitationController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate, :validate_phone

  def invite
    invitee = User.find_by_mobile_number(params[:mobile_number]) || User.create(invitee_params)
    connection = Connection.find_or_create(@user.id, invitee.id)
    render json: invitee.only_app_attrs_for_friend_with_ckey(@user)
  end

  def has_app
    friend = User.find_by_mobile_number(params[:mobile_number])
    if friend && friend.has_app?
      render json: { status: 'success', has_app: 'true' }
    else
      render json: { status: 'success', has_app: 'false' }
    end
  end

  private

  def invitee_params
    params.permit(:first_name, :last_name, :mobile_number)
  end

  def validate_phone
    raw_phone = params[:mobile_number]
    unless GlobalPhone.validate(raw_phone)
      Rails.logger.error("Invitation: invalid mobile number: #{raw_phone}")
      render json: { status: 'failure',
                     title: 'Bad Phone',
                     msg: "Phone number: #{params[:mobile_number]} is not valid.\n\nPlease kill #{APP_CONFIG[:app_name]} then enter a valid phone number for this person in your address book.\n\nThen try again." }
      return false
    end
    true
  end
end
