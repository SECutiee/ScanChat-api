# frozen_string_literal: true

require 'roda'
require 'json'

module Chats
  # Web Controller for Chats API
  class Api < Roda
    plugin :halt

    # rubocop:disable Metrics/BlockLength
    route do |r|
      response['Content-Type'] = 'application/json'

      r.root do
        response.status = 200
        { message: 'ChatsAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      r.on @api_root do
        r.on 'chatrooms' do
          @chatr_route = "#{@api_root}/chatrooms"

          r.on String do |chatr_id|
            r.on 'messages' do
              @mes_route = "#{@api_root}/chatrooms/#{chatr_id}/messages"

              # GET api/v1/chatrooms/[chatr_id]/messages/[mes_id]
              r.get String do |mes_id|
                mes = Message.where(chatroom_id: chatr_id, id: mes_id).first
                mes ? mes.to_json : raise('Message not found')
              rescue StandardError => e
                r.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/chatrooms/[chatr_id]/messages
              r.get do
                output = { data: Chatroom.first(id: chatr_id).messages }
                JSON.pretty_generate(output)
              rescue StandardError
                r.halt 404, { message: 'Could not find messages' }.to_json
              end

              # POST api/v1/chatrooms/[chatr_id]/messages
              r.post do
                new_data = JSON.parse(r.body.read)
                chatr = Chatroom.first(id: chatr_id)
                new_mes = chatr.add_message(new_data)
                raise 'Could not create Message' unless new_mes

                response.status = 201
                response['Location'] = "#{@mes_route}/#{new_mes.id}"
                { message: 'Message sended', data: new_mes }.to_json
              #   else
              #     r.halt 400, { message: 'Could not send the message' }.to_json
              #   end
              # rescue StandardError
              #   r.halt 500, { message: 'Database eror' }.to_json
              rescue Sequel::MassAssignmentRestriction
                Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
                r.halt 400, {message: "Illegal Attributes"}.to_json
              rescue StandardError => e
                r.halt 500, {message: e.message}.to_json
              end
            end

            # GET api/v1/chatrooms/[chatr_id]
            r.get do
              chatr = Chatroom.first(id: chatr_id)
              chatr ? chatr.to_json : raise('Chatroom not found')
            rescue StandardError => e
              r.halt 404, { message: e.message }.to_json
            end
          end

          # GET api/v1/chatrooms
          r.get do
            output = { data: Chatroom.all }
            JSON.pretty_generate(output)
          rescue StandardError
            r.halt 404, { message: 'Could not find chatrooms' }.to_json
          end

          # POST api/v1/chatrooms
          r.post do
            new_data = JSON.parse(r.body.read)
            new_chatr = Chatroom.new(new_data)
            raise 'Could not create Chatroom' unless new_chatr.save

            response.status = 201
            response['Location'] = "#{@chatr_route}/#{new_chatr.id}"
            { message: 'Chatroom created', data: new_chatr }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            r.halt 400, {message: "Illegal Attributes"}.to_json
          rescue StandardError => e
            Api.logger.error "UNKNOWN ERROR: #{e.message}"
            r.halt 500, {message: 'Unknwon server error'}.to_json
          end
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
