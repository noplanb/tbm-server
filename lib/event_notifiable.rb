module EventNotifiable
  def id_for_events
    id
  end

  def notify_state_changed
    initiator = self.class.name.underscore
    Zazo::Tool::EventDispatcher.emit([initiator, aasm.current_state],
                         initiator: initiator,
                         initiator_id: id_for_events,
                         data: { event: aasm.current_event,
                                 from_state: aasm.from_state,
                                 to_state: aasm.to_state })
  end
end
