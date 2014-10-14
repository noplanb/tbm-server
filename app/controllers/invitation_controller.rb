class InvitationController < ApplicationController
  
  def invite
    invitee = User.find_by_mobile_number(params[:invitee][:mobile_number]) || User.create(invitee_params)
    user = User.find_by_mkey(params[:mkey])
    raise "Unable to find user with mkey: #{meky}" unless user
    connection = Connection.find_or_create(user.id, invitee.id)
    render :json => invitee.attributes.merge({connection_status: connection.status})
  end
  
  
  def invitee_params
    params.require(:invitee).permit(:first_name, :last_name, :mobile_number)
  end
end
