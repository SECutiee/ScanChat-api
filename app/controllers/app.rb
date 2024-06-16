# frozen_string_literal: true

require 'roda'
require 'json'
require_relative 'helpers'

module ScanChat
  # Web controller for ScanChat API
  class Api < Roda
    plugin :halt
    plugin :all_verbs
    plugin :multi_route
    plugin :request_headers

    include SecureRequestHelpers

    UNAUTH_MSG = { message: 'Unauthorized Request' }.to_json

    route do |routing|
      # Api.logger.info 'Start routing'
      response['Content-Type'] = 'application/json'

      secure_request?(routing) ||
        routing.halt(403, { message: 'TLS/SSL Required' }.to_json)

      begin
        @auth = authorization(routing.headers)
        @auth_account = @auth[:account] if @auth
        Api.logger.info "Authenticated Account: #{@auth_account}"
      rescue AuthToken::InvalidTokenError
        Api.logger.info 'Invalid Token'
        routing.halt 403, { message: 'Invalid auth token' }.to_json
      rescue AuthToken::ExpiredTokenError
        Api.logger.info 'Expired Token'
        routing.halt 403, { message: 'Expired auth token' }.to_json
      end

      routing.root do
        { message: 'ScanChatAPI up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          @api_root = 'api/v1'
          routing.multi_route
        end
      end
    end
  end
end
