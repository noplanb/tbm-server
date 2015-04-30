module EventNotifiable
  def event_id
    id
  end

  def notify_state_changed
    initiator = self.class.name.underscore
    EventDispatcher.emit("#{initiator}:#{aasm.current_state}",
                         initiator: initiator,
                         initiator_id: event_id,
                         data: { event: aasm.current_event,
                                 from_state: aasm.from_state,
                                 to_state: aasm.to_state })
  end
end
