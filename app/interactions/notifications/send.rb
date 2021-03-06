class Notifications::Send < ActiveInteraction::Base
  object :sender,   class: ::User # message sender
  object :receiver, class: ::User # message receiver
  object :kvstore

  def execute
    send_notification
    Messages::TriggerEvent.run(
      sender: sender, receiver: receiver,
      message: message, type: 'notification')
  end

  def message
    @message ||= kvstore.decorate_with(:default)
  end

  protected

  def send_notification
    payload = new_schema_allowed? || !message.type?(:video) ?
      payload_with_new_schema : payload_with_legacy_schema
    notification_receiver.push_user.try(:send_notification,
      base_notification.merge(payload: payload))
  end

  def host
    Figaro.env.domain_name
  end

  def notification_receiver
    User.new
  end

  def new_schema_allowed?
    notification_receiver; false
  end

  def base_notification
    {}
  end

  def payload_with_legacy_schema
    {}
  end

  def payload_with_new_schema
    {}
  end
end
