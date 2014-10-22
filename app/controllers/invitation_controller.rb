class InvitationController < ApplicationController
  
  def invite
    invitee = User.find_by_mobile_number(params[:mobile_number]) || User.create(invitee_params)
    user = User.find_by_auth(params[:auth])
    raise "Unable to find user with auth: #{auth}" unless user
    connection = Connection.find_or_create(user.id, invitee.id)
    render :json => invitee.only_app_attrs_for_friend
  end
  
  
  def invitee_params
    params.permit(:first_name, :last_name, :mobile_number)
  end
end
