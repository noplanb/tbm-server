class WriteLog
  def self.info(context, message, settings = {})
    klass_name = context.instance_of?(Class) ? context.name : context.class.name
    Rails.logger.tagged(klass_name) { Rails.logger.info message }
    Rails.syslogger.info("[#{klass_name}] #{message}") if %w(production staging).include? Rails.env
    Rollbar.send(settings[:rollbar], "[#{klass_name}] #{message}") if settings[:rollbar]
  end
end
