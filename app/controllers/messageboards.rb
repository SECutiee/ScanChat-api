# frozen_string_literal: true

require_relative 'app'

module ScanChat
  # Web controller for ScanChat API
  class Api < Roda
    route('messageboards') do |routing|
      @chatroom_route = "#{@api_root}/messageboards"

      routing.on String do |thread_id|
        routing.on 'messages' do
          @mes_route = "#{@api_root}/messageboards/#{thread_id}/messages"

          # GET api/v1/messageboards/[thread_id]/messages/[mes_id]
          routing.get String do |mes_id|
            mes = Message.where(thread_id:, id: mes_id).first
            mes ? mes.to_json : raise('Message not found')
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end

          # GET api/v1/messageboards/[thread_id]/messages
          routing.get do
            output = { data: Thread.first(id: thread_id).messages }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find messages' }.to_json
          end

          # POST api/v1/messageboards/[thread_id]/messages
          routing.post do
            new_data = JSON.parse(routing.body.read)
            thread = Thread.first(id: thread_id)
            new_mes = thread.add_message(new_data)
            raise 'Could not create Message' unless new_mes

            response.status = 201
            response['Location'] = "#{@mes_route}/#{new_mes.id}"
            { message: 'Message sended', data: new_mes }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            routing.halt 500, { message: e.message }.to_json
          end
        end

        # GET api/v1/messageboards/[thread_id]
        routing.get do
          # thread = Thread.first(id: thread_id)
          # thread ? thread.to_json : raise('Messageboard not found')
          messageboard = Messageboard.first(thread_id:)
          raise 'Messageboard not found' unless messageboard

          output = messageboard
          JSON.pretty_generate(output)
          messageboard = Messageboard.first(thread_id:)
          raise 'Messageboard not found' unless messageboard

          output = messageboard
          JSON.pretty_generate(output)
        rescue StandardError => e
          Api.logger.error "UNKNOWN ERROR: #{e.message}"
          routing.halt 404, { message: e.message }.to_json
        end
      end

      # DELETE api/v1/messageboards/[thread_id]
      routing.delete String do |thread_id|
        thread = Thread.first(id: thread_id)
        raise 'Messageboard not found' unless thread

        DeleteMessageboardByThreadId(thread_id:)
        { message: 'Messageboard deleted' }.to_json
      rescue StandardError => e
        Api.logger.error "UNKNOWN ERROR: #{e.message}"
        routing.halt 404, { message: e.message }.to_json
      end

      # TODO: problem is that we only get msgb and not the attributes in threads
      # GET api/v1/messageboards
      routing.get do
        account = Account.first(username: @auth_account['username'])
        messageboards = account.messageboards
        JSON.pretty_generate(data: messageboards)
      rescue StandardError
        routing.halt 403, { message: 'Could not find any messageboards' }.to_json
      end

      # POST api/v1/messageboards
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_msgb = Messageboard.new(new_data)
        raise('Could not save messageboard') unless new_msgb.save

        response.status = 201
        response['Location'] = "#{@msgb_route}/#{new_msgb.id}"
        { message: 'Messageboard saved', data: new_msgb }.to_json
      rescue Sequel::MassAssignmentRestriction
        Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
        routing.halt 400, { message: 'Illegal Attributes' }.to_json
      rescue StandardError => e
        Api.logger.error "UNKOWN ERROR: #{e.message}"
        routing.halt 500, { message: 'Unknown server error' }.to_json
      end
    end
  end
end
