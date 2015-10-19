class WriteLog
  def self.info(context, message, settings = {})
    prefix = get_class_name context
    logging_local   prefix, message
    logging_syslog  prefix, message
    logging_rollbar prefix, message, settings[:rollbar] if settings[:rollbar]
  end

  def self.debug(context, message)
    prefix = "#{get_class_name context} [DEBUG]"
    logging_local  prefix, message
    logging_syslog prefix, message
  end

  private

  def self.logging_local(prefix, message)
    Rails.logger.tagged(prefix) { Rails.logger.info message }
  end

  def self.logging_syslog(prefix, message)
    Rails.syslogger.info("[#{prefix}] #{message}") if %w(production staging).include? Rails.env
  end

  def self.logging_rollbar(prefix, message, method = :error)
    Rollbar.send(method, "[#{prefix}] #{message}") if Rollbar.respond_to? method
  end

  def self.get_class_name(context)
    context.instance_of?(Class) ? context.name : context.class.name
  end
end
