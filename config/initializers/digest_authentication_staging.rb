module ActionController::HttpAuthentication::Digest
  class Unauthorized < Exception; end

  def validate_digest_response(request, realm, &password_procedure)
    secret_key  = secret_token(request)
    credentials = decode_credentials_header(request)
    valid_nonce = validate_nonce(secret_key, request, credentials[:nonce])

    if valid_nonce && realm == credentials[:realm] && opaque(secret_key) == credentials[:opaque]
      password = password_procedure.call(credentials[:username])
      return false unless password

      method = request.env['rack.methodoverride.original_method'] || request.env['REQUEST_METHOD']
      uri    = credentials[:uri]

      expected_responses = []
      status = [true, false].any? do |trailing_question_mark|
        [true, false].any? do |password_is_ha1|
          _uri = trailing_question_mark ? uri + "?" : uri
          expected = expected_response(method, _uri, credentials, password, password_is_ha1)
          expected_responses << expected
          expected == credentials[:response]
        end
      end

      fail Unauthorized, { expected_responses: expected_responses, credentials: credentials }.inspect if !status && Rails.env.staging?
      status
    end
  end
end
