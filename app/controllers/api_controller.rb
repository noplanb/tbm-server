class ApiController < ApplicationController
  include Zazo::Tools::ApiController

  before_action :authenticate
  before_action :save_client_info

  def request_http_digest_authentication(realm = REALM)
    super(realm, { status: :unauthorized }.to_json)
  end
end
