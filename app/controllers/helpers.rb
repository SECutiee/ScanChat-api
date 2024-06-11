# frozen_string_literal: true

module ScanChat
  # Methods for controllers to mixin
  module SecureRequestHelpers
    class UnauthorizedRequestError < StandardError; end
    class NotFoundError < StandardError; end

    def secure_request?(routing)
      routing.scheme.casecmp(Api.config.SECURE_SCHEME).zero?
    end

    def authenticated_account(headers)
      return nil unless headers['AUTHORIZATION']

      scheme, auth_token = headers['AUTHORIZATION'].split
      return nil if auth_token.nil?
      return nil unless scheme.match?(/^Bearer$/i)

      account_payload = AuthToken.new(auth_token).payload
      Api.logger.info "Account Payload: #{account_payload}"
      Account.first(username: account_payload['attributes']['username'])
    end
  end
end
