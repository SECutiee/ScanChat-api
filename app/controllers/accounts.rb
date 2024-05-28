# frozen_string_literal: true

require 'roda'
require_relative 'app'

module ScanChat
  # Web controller for ScanChat API
  class Api < Roda
    route('accounts') do |r|
      @acc_route = "#{@api_root}/accounts"
      # POST api/v1/accounts
      r.is do
        r.post do
          new_data = JSON.parse(r.body.read)
          new_account = Account.new(new_data)
          raise 'Could not save account' unless new_account.save

          response.status = 201
          response['Location'] = "#{@acc_route}/#{new_account[:username]}"
          { message: 'Account created', data: new_account }.to_json
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
          r.halt 400, { message: 'Illegal Attributes' }.to_json
        rescue StandardError => e
          Api.logger.error 'Unknown error saving account'
          r.halt 500, { message: e.message }.to_json
        end
      end

      r.on String do |username|
        r.is do
          # GET api/v1/accounts/[username]
          r.get do
            account = Account.first(username:)
            account ? account.to_json : raise('Account not found')
          rescue StandardError => e
            Api.logger.error "UNKNOWN ERROR: #{e.message}"
            r.halt 404, { message: e.message }.to_json
          end
        end

        r.on 'chatrooms' do
          @acc_chatrooms_route = "#{@acc_route}/#{username}/chatrooms"

          # GET api/v1/accounts/[username]/chatrooms
          r.is do
            r.get do
              account = ScanChat::Account.first(username:) || raise('Account not found')

              # Fetch all threads belonging to the account
              # TODO change to account.owned_threads
              threads = ScanChat::Thread.where(owner_id: account.id, thread_type: 'chatroom').all

              # Collect all chatrooms belonging to the threads, filtering out nil values
              chatrooms = threads.filter_map(&:chatroom) || raise('no chatrooms found for this account not found')

              output = { data: chatrooms }
              JSON.pretty_generate(output)
            rescue StandardError => e
              Api.logger.error "UNKNOWN ERROR: #{e.message}"
              r.halt 404, { message: e.message }.to_json
            end

            # POST api/v1/accounts/[username]/chatrooms
            r.post do
              new_data = JSON.parse(r.body.read)
              # Api.logger.info "Received request to create chatroom: #{new_data}"

              account = Account.first(username:) || raise('Account not found')

              # Api.logger.info "Found account: #{account.username}"

              new_chatroom = CreateChatroomForOwner.call(owner_id: account.id, name: new_data['name'],
                                                         is_private: new_data['is_private'])
              new_chatroom = CreateChatroomForOwner.call(owner_id: account.id, name: new_data['name'],
                                                         is_private: new_data['is_private'])
              raise 'Could not create Chatroom' unless new_chatroom

              # Api.logger.info "Created new chatroom: #{new_chatroom.id}"

              new_chatroom.description = new_data['description'] if new_data['description']
              new_chatroom.expiration_date = new_data['expiration_date'] if new_data['expiration_date']
              new_chatroom.save
              new_data.delete('name')
              new_data.delete('is_private')
              new_data.delete('description')
              new_data.delete('expiration_date')
              # Api.logger.info "Sliced new data: #{new_data}"
              new_chatroom.update(new_data)

              response.status = 201
              response['Location'] = "#{@acc_chatrooms_route}/#{new_chatroom.thread_id}"
              r.halt 201, { message: 'Chatroom created', data: new_chatroom }.to_json
              rescue Sequel::MassAssignmentRestriction
                Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
                r.halt 400, { message: 'Illegal Attributes' }.to_json
              rescue StandardError => e
                Api.logger.error "UNKNOWN ERROR: #{e.message}"
                r.halt 500, { message: 'Unknown server error' }.to_json
            end
          end
        end

        r.on 'messageboards' do
          @acc_messageboards_route = "#{@acc_route}/#{username}/messageboards"

          # GET api/v1/accounts/[username]/messageboards
          r.is do
            r.get do
              account = ScanChat::Account.first(username:) || raise('Account not found')

              # Fetch all threads belonging to the account
              # TODO change to account.owned_threads
              threads = ScanChat::Thread.where(owner_id: account.id, thread_type: 'messageboard').all

              # Collect all messageboards belonging to the threads, filtering out nil values
              messageboards = threads.filter_map(&:messageboard) || raise('no messageboards found for this account not found')

              output = { data: messageboards }
              JSON.pretty_generate(output)
            rescue StandardError => e
              Api.logger.error "UNKNOWN ERROR: #{e.message}"
              r.halt 404, { message: e.message }.to_json
            end

            # POST api/v1/accounts/[username]/messageboards
            r.post do
              new_data = JSON.parse(r.body.read)
              # Api.logger.info "Received request to create messageboard: #{new_data}"

              account = Account.first(username:) || raise('Account not found')
              account = Account.first(username:) || raise('Account not found')

              # Api.logger.info "Found account: #{account.username}"

              new_messageboard = CreateMessageboardForOwner.call(owner_id: account.id, name: new_data['name'],
                                                                 is_anonymous: new_data['is_anonymous'])
              new_messageboard = CreateMessageboardForOwner.call(owner_id: account.id, name: new_data['name'],
                                                                 is_anonymous: new_data['is_anonymous'])
              raise 'Could not create Messageboard' unless new_messageboard

              # Api.logger.info "Created new messageboard: #{new_messageboard.id}"

              new_messageboard.description = new_data['description'] if new_data['description']
              new_messageboard.expiration_date = new_data['expiration_date'] if new_data['expiration_date']
              new_messageboard.save
              new_data.delete('name')
              new_data.delete('is_anonymous')
              new_data.delete('description')
              new_data.delete('expiration_date')
              # Api.logger.info "Sliced new data: #{new_data}"
              new_messageboard.update(new_data)

              response.status = 201
              response['Location'] = "#{@acc_messageboards_route}/#{new_messageboard.thread_id}"
              r.halt 201, { message: 'Messageboard created', data: new_messageboard }.to_json
              rescue Sequel::MassAssignmentRestriction
                Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
                r.halt 400, { message: 'Illegal Attributes' }.to_json
              rescue StandardError => e
                Api.logger.error "UNKNOWN ERROR: #{e.message}"
                r.halt 500, { message: 'Unknown server error' }.to_json
            end
          end
        end

        r.is 'joined_chatrooms' do
          r.get do
            account = ScanChat::Account.first(username:) || raise('Account not found')

            # Collect all chatrooms belonging to the threads, filtering out nil values
            chatrooms = account.joined_chatrooms || raise('no joined_chatrooms found for this account not found')

            output = { data: chatrooms }
            JSON.pretty_generate(output)
          rescue StandardError => e
            Api.logger.error "UNKNOWN ERROR: #{e.message}"
            r.halt 404, { message: e.message }.to_json
          end
        end
      end
    end
  end
end
