# frozen_string_literal: true

require 'roda'
require 'json'

module ScanChat
  # Web Controller for ScanChat API
  class Api < Roda
    plugin :halt

    # rubocop:disable Metrics/BlockLength
    route do |r|
      response['Content-Type'] = 'application/json'

      r.root do
        response.status = 200
        { message: 'ScanChatAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      r.on @api_root do
        r.on 'accounts' do
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

        r.on 'chatrooms' do
          @chatroom_route = "#{@api_root}/chatrooms"

          r.on String do |thread_id|
            r.on 'messages' do
              @mes_route = "#{@api_root}/chatrooms/#{thread_id}/messages"

              # GET api/v1/chatrooms/[thread_id]/messages/[mes_id]
              r.get String do |mes_id|
                mes = Message.where(thread_id:, id: mes_id).first
                mes ? mes.to_json : raise('Message not found')
              rescue StandardError => e
                r.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/chatrooms/[thread_id]/messages
              r.get do
                output = { data: Thread.first(id: thread_id).messages }
                JSON.pretty_generate(output)
              rescue StandardError
                r.halt 404, { message: 'Could not find messages' }.to_json
              end

              # POST api/v1/chatrooms/[thread_id]/messages
              r.post do
                new_data = JSON.parse(r.body.read)
                thread = Thread.first(id: thread_id)
                new_mes = thread.add_message(new_data)
                raise 'Could not create Message' unless new_mes

                response.status = 201
                response['Location'] = "#{@mes_route}/#{new_mes.id}"
                { message: 'Message sended', data: new_mes }.to_json
              rescue Sequel::MassAssignmentRestriction
                Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
                r.halt 400, { message: 'Illegal Attributes' }.to_json
              rescue StandardError => e
                r.halt 500, { message: e.message }.to_json
              end
            end

            # GET api/v1/chatrooms/[thread_id]
            r.get do
              thread = Thread.first(id: thread_id)
              thread ? thread.to_json : raise('Chatroom not found')
            rescue StandardError => e
              r.halt 404, { message: e.message }.to_json
            end
          end

          # GET api/v1/chatrooms
          r.get do
            output = { data: Thread.where(thread_type: 'chatroom').all }
            JSON.pretty_generate(output)
          rescue StandardError
            r.halt 404, { message: 'Could not find any Chatrooms' }.to_json
          end

          # POST api/v1/chatrooms
          r.post do
            new_data = JSON.parse(r.body.read)
            new_thread = Thread.new(new_data)
            raise 'Could not create Chatroom' unless new_thread.save

            response.status = 201
            response['Location'] = "#{@thread_route}/#{new_thread.id}"
            { message: 'Thread created', data: new_thread }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            r.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            Api.logger.error "UNKNOWN ERROR: #{e.message}"
            r.halt 500, { message: 'Unknown server error' }.to_json
          end
        end

        r.on 'messageboards' do
          @chatroom_route = "#{@api_root}/messageboards"

          r.on String do |thread_id|
            r.on 'messages' do
              @mes_route = "#{@api_root}/messageboards/#{thread_id}/messages"

              # GET api/v1/messageboards/[thread_id]/messages/[mes_id]
              r.get String do |mes_id|
                mes = Message.where(thread_id:, id: mes_id).first
                mes ? mes.to_json : raise('Message not found')
              rescue StandardError => e
                r.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/messageboards/[thread_id]/messages
              r.get do
                output = { data: Thread.first(id: thread_id).messages }
                JSON.pretty_generate(output)
              rescue StandardError
                r.halt 404, { message: 'Could not find messages' }.to_json
              end

              # POST api/v1/messageboards/[thread_id]/messages
              r.post do
                new_data = JSON.parse(r.body.read)
                thread = Thread.first(id: thread_id)
                new_mes = thread.add_message(new_data)
                raise 'Could not create Message' unless new_mes

                response.status = 201
                response['Location'] = "#{@mes_route}/#{new_mes.id}"
                { message: 'Message sended', data: new_mes }.to_json
              rescue Sequel::MassAssignmentRestriction
                Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
                r.halt 400, { message: 'Illegal Attributes' }.to_json
              rescue StandardError => e
                r.halt 500, { message: e.message }.to_json
              end
            end

            # GET api/v1/messageboards/[thread_id]
            r.get do
              thread = Thread.first(id: thread_id)
              thread ? thread.to_json : raise('Messageboard not found')
            rescue StandardError => e
              r.halt 404, { message: e.message }.to_json
            end
          end

          # GET api/v1/messageboards
          r.get do
            output = { data: Thread.where(thread_type: 'messageboard').all }
            JSON.pretty_generate(output)
          rescue StandardError
            r.halt 404, { message: 'Could not find any Messageboards' }.to_json
          end

          # POST api/v1/messageboards
          r.post do
            new_data = JSON.parse(r.body.read)
            new_thread = Thread.new(new_data)
            raise 'Could not create Messageboard' unless new_thread.save

            response.status = 201
            response['Location'] = "#{@thread_route}/#{new_thread.id}"
            { message: 'Thread created', data: new_thread }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            r.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            Api.logger.error "UNKNOWN ERROR: #{e.message}"
            r.halt 500, { message: 'Unknown server error' }.to_json
          end
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
