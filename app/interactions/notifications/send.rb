class Notifications::Send < ActiveInteraction::Base
  object :sender, class: ::User   # message sender
  object :receiver, class: ::User # message receiver
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
