class RequestDocs
  DOCS_FOLDER = '/docs'
  DEFAULT_USERNAME = 'docs'
  DEFAULT_PASSWORD = 'password'

  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    if (req.get? || req.head?) && req.path_info.chomp('/') =~ /#{Regexp.new(DOCS_FOLDER)}\/.*+/
      basic_auth_app(static_app(@app)).call(env)
    else
      @app.call(env)
    end
  end

  private

  def static_app(app)
    Rack::Static.new(app, urls: [DOCS_FOLDER])
  end

  def basic_auth_app(app)
    Rack::Auth::Basic.new(app) do |u, p|
      u == username && p == password
    end
  end

  def username
    ENV['http_documentation_username'] || DEFAULT_USERNAME
  end

  def password
    ENV['http_documentation_password'] || DEFAULT_PASSWORD
  end
end
