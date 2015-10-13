module HandleWithManager
  def handle_with_manager(manager)
    if manager.do
      yield if block_given?
      manager.log_messages :success
      head :ok
    else
      manager.log_messages :failure
      render status: :ok, json: { errors: manager.errors }
    end
  end
end
