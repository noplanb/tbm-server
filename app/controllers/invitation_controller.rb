class InvitationController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate
  before_action :find_friend, only: [:update_friend]
  before_action :validate_phone, except: [:direct_invite_message, :update_friend]
  before_action :ensure_emails_is_array, except: [:direct_invite_message]

  def invite
    invitee = User.find_by_raw_mobile_number(params[:mobile_number]) || User.create(invitee_params)
    invitee.emails += invitee_params[:emails]
    invitee.save
    Connection.find_or_create(@user.id, invitee.id)
    invitee.invite! if invitee.may_invite?
    trigger_invitation_sent(current_user, invitee)
    render json: invitee.only_app_attrs_for_friend_with_ckey(@user)
  end

  def update_friend
    @friend.attributes = friend_params.except(:emails)
    @friend.emails += friend_params[:emails]
    @friend.save
    render json: @friend.only_app_attrs_for_friend_with_ckey(@user)
  end

  def has_app
    friend = User.find_by_raw_mobile_number(params[:mobile_number])
    if friend && friend.app?
      render json: { status: 'success', has_app: 'true' }
    else
      render json: { status: 'success', has_app: 'false' }
    end
  end

  def direct_invite_message
    render json: trigger_direct_invite_message(current_user)
  end

  private

  def ensure_emails_is_array
    params[:emails] = Array.wrap(params[:emails])
  end

  def invitee_params
    params.permit(:first_name, :last_name, :mobile_number, :emails, emails: [])
  end

  def direct_invite_message_params
    params.permit(:mkey, :messaging_platform, :message_status)
  end

  def friend_params
    params.permit(:mkey, :first_name, :last_name, :mobile_number, :emails, emails: [])
  end

  def find_friend
    @friend = User.find_by_mkey(friend_params[:mkey])
    render json: { error: 'user not found' }, status: :not_found if @friend.nil?
  end

  def validate_phone
    raw_phone = params[:mobile_number]
    unless GlobalPhone.validate(raw_phone)
      Rails.logger.error("Invitation: invalid mobile number: #{raw_phone}")
      render json: { status: 'failure',
                     title: 'Bad Phone',
                     msg: "Phone number: #{params[:mobile_number]} is not valid.\n\nPlease kill #{Settings.app_name} then enter a valid phone number for this person in your address book.\n\nThen try again." }
      return false
    end
    true
  end

  def trigger_invitation_sent(inviter, invitee)
    EventDispatcher.emit(%w(user invitation_sent), initiator: 'user',
                                                   initiator_id: inviter.id_for_events,
                                                   target: 'user',
                                                   target_id: invitee.id_for_events,
                                                   data: {
                                                     inviter_id: inviter.id_for_events,
                                                     invitee_id: invitee.id_for_events
                                                   },
                                                   raw_params: invitee_params)
  end

  def trigger_direct_invite_message(inviter)
    invitee_id_for_events = direct_invite_message_params[:mkey]
    messaging_platform = direct_invite_message_params[:messaging_platform]
    message_status = direct_invite_message_params[:message_status]
    EventDispatcher.emit(%w(user invitation direct_invite_message), initiator: 'user',
                                                                    initiator_id: inviter.id_for_events,
                                                                    target: 'user',
                                                                    target_id: invitee_id_for_events,
                                                                    data: {
                                                                      inviter_id: inviter.id_for_events,
                                                                      invitee_id: invitee_id_for_events,
                                                                      messaging_platform: messaging_platform,
                                                                      message_status: message_status
                                                                    },
                                                                    raw_params: direct_invite_message_params)
  end
end
