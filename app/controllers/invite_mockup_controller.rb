class InviteMockupController < ApplicationController
  TEST_USERS = [
    {first_name:"Ansel", last_name:"Adams", mobile_number:"aa"},
    {first_name:"Charlie", last_name:"Coltrain"},
    {first_name:"Dave", last_name:"Downey"},
    {first_name:"Elmer", last_name:"Elwin"},
    {first_name:"Farley", last_name:"Farzaneh"},
    {first_name:"George", last_name:"Gill"},
    {first_name:"Harley", last_name:"Harrop"},
    {first_name:"Inez", last_name:"Irksome"},
    {first_name:"Jim", last_name:"Johnson"},
  ]

  INVITEE = {first_name:"Barbara", last_name:"Boxer", mobile_number:"bb", device_platform:"ios"}


  def index
    destroy_invitee
    setup_users
    make_user_connections(:full)
    @users = [TEST_USERS.first, INVITEE]
  end

  def setup_users
    TEST_USERS.each{|u| User.create(u) if User.where(u).blank?}
  end

  def test_users
    TEST_USERS.map{|u| User.where(u).first}
  end

  def destroy_invitee
    User.where(mobile_number: "bb").each{|u| u.destroy}
    User.where(first_name:"Barbara", last_name:"Boxer").each{|u| u.destroy}
  end


  def clear_user_connections
    test_users.each{ |u| Connection.for_user_id(u.id).each{|c| c.destroy} }
  end

  def make_user_connections(state)
    clear_user_connections
    creator = test_users.first
    creator.update_attribute(:device_platform, "ios")
    targets = []
    case state
    when :full
      targets = test_users.last(8)
    when :not_full
      targets = test_users.last(4)
    when :empty
    end
    targets.each{|target| c=Connection.find_or_create(creator.id, target.id)}
  end
end
