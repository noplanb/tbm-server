class Object
  def switch_db(env = nil)
    SwitchDB.new(env).call
  end

  class SwitchDB
    VARIABLES_MATCHING = {
      database: :db_name,
      username: :db_username,
      password: :db_password,
      host:     :db_host,
      port:     :db_port
    }

    attr_reader :env

    def initialize(env)
      @env = env || Rails.env
    end

    def call
      if Rails.env.development?
        switch_db
      else
        Logger.new(STDOUT).info("Database switching is disabled for #{Rails.env} environment")
      end
    end

    private

    def switch_db
      db_config = db_configuration
      VARIABLES_MATCHING.each do |db_var, env_var|
        db_config[db_var.to_s] = get_env_variable(env_var.to_s)
      end
      ActiveRecord::Base.establish_connection(db_config)
      Logger.new(STDOUT).info("Successfully changed to #{env} environment")
    end

    def db_configuration
      config = Rails.configuration.database_configuration
      raise ArgumentError, "Invalid environment: #{env}" unless config[env].present?
      config[env]
    end

    def get_env_variable(var)
      @env_config ||= YAML.load_file('config/application.yml')
      (@env_config[env] || {})[var] || @env_config[var]
    end
  end
end
