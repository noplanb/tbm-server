require 'rails_helper'

RSpec.describe 'BlocksBadClients', type: :request do
  before { ENV['domain_name'] = 'zazo.test' }

  context 'from 10.0.1.5' do
    context 'example.com' do
      specify 'blocks request' do
        get '/admin', nil, 'HTTP_HOST' => 'example.com', 'REMOTE_ADDR' => '10.0.1.5'
        expect(response).to have_http_status(403)
      end
    end
    context 'zazo-test.10.0.1.5.xip.io' do
      specify 'allows request' do
        get '/', nil, 'HTTP_HOST' => 'zazo-test.10.0.1.5.xip.io', 'REMOTE_ADDR' => '10.0.1.5'
        expect(response).to have_http_status(200)
      end
    end
  end

  context 'from 127.0.0.1' do
    ['example.com', 'zazo.dev', 'zazo-test.elasticbeanstalk.com', 'test.zazoapp.com'].each do |host|
      context host do
        specify 'allows request' do
          get '/', nil, 'HTTP_HOST' => host
          expect(response).to have_http_status(200)
        end
        specify 'allows request' do
          expect do
            get '/admin', nil, 'HTTP_HOST' => host
          end.to raise_error(ActionController::RoutingError)
        end
      end
    end
  end
end
