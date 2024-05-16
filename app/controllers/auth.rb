# frozen_string_literal: true

require 'roda'
require_relative 'app'

module ScanChat
  # Web controller for ScanChat API
  class Api < Roda
    route('auth') do |r|
      r.is 'authenticate' do
        # POST /api/v1/auth/authenticate
        r.post do
          credentials = JSON.parse(request.body.read, symbolize_names: true)
          auth_account = AuthenticateAccount.call(credentials)
          auth_account.to_json
        rescue UnauthorizedError => e
          puts [e.class, e.message].join ': '
          r.halt '403', { message: 'Invalid credentials' }.to_json
        end
      end
    end
  end
end