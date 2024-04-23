# frozen_string_literal: true

require 'roda'
require 'json'
require_relative '../models/chatroom'
require_relative '../models/message'

module Chats
  # Web Controller for Chats API
  class Api < Roda
    plugin :environments
    plugin :halt

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

          # GET api/v1/chatrooms
          r.get do
            response.status = 200 # TODO: continue here (learn sequel gem first)
            output = { chatroom_ids: Chatroom.all_ids }
            JSON.pretty_generate(output)
          end

          r.on String do |chatroom_id|
          end
          # GET api/v1/chatrooms/:id
          r.get String do |id|
            response.status = 200
            Chatroom
              .rescue StandardError
            r.halt 404, { message: 'Chatroom not found', id: }.to_json
          end

          # POST api/v1/chatrooms
          r.is do
            r.post do
              new_data = JSON.parse(r.body.read)
              new_chatroom = Chatroom.new(new_data)

              if new_chatroom.save
                response.status = 201
                { message: 'Chatroom created', id: new_chatroom.id }.to_json
              else
                r.halt 400, { message: 'Could not create Chatroom' }.to_json
              end
            end
          end

          r.on String do |chatroom_id|
            r.on 'messages' do
              # POST api/v1/chatrooms/:id/messages
              r.post do
                new_data = JSON.parse(r.body.read)
                Chatroom.add_message(chatroom_id, new_data['sender_id'], new_data['content'])
                response.status = 201
                { message: 'Message added to Chatroom', chatroom_id: }.to_json
              end
            end
          end
        end
      end
    end
  end
end
