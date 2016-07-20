class Notifications::Send < ActiveInteraction::Base
  object :sender, class: ::User
  object :receiver, class: ::User
  object :kvstore

  protected

  def host
    Figaro.env.domain_name
  end

  def message
    @message ||= Kvstore::Wrapper.new(kvstore)
  end

  def new_schema_allowed?(user)
    false
  end

  def trigger_event(name)

  end
end
