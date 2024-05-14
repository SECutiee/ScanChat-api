# frozen_string_literal: true

require 'roda'
require_relative 'app'

module ScanChat
  # Web controller for Credence API
  class Api < Roda
    route('accounts') do |r|
      @acc_route = "#{@api_root}/accounts"

      r.on String do |username|
        # GET api/v1/accounts/[username]
        r.get do
          account = Account.first(username:)
          account ? account.to_json : raise('Account not found')
        rescue StandardError => e
          r.halt 404, { message: e.message }.to_json
        end
      end

      # POST api/v1/accounts
      r.post do
        new_data = JSON.parse(r.body.read)
        new_account = Account.new(new_data)
        raise 'Could not save account' unless new_account.save

        response.status = 201
        response['Location'] = "#{@acc_route}/#{new_account[:username]}"
        { message: 'Account created', data: new_account }.to_json
      rescue Sequel::MassAssignmentRestriction
        Aoi.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
        r.halt 400, { message: 'Illegal Attributes' }.to_json
      rescue StandardError => e
        Aoi.logger.error 'Unknown error saving account'
        r.halt 500, { message: e.message }.to_json
      end
    end
  end
end
