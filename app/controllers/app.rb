# frozen_string_literal: true

require 'roda'
require 'json'
require_relative '../models/chat'

module Chats
  # Web Controller for Chats API
  class Api < Roda
    plugin :environments
    plugin :halt

    Chatroom.setup

    route do |r|
      r.root do
        response.status = 200
        { message: 'Chats API up at /api/v1' }.to_json
      end
      r.on 'api' do
        r.on 'v1' do
          r.on 'chatrooms' do
            # GET api/v1/chatrooms/:id
            r.get String do |id|
              response.status = 200
              Chatroom.find(id).to_json
            rescue StandardError
              r.halt 404, { message: 'Chatroom not found', id: }.to_json
            end

            # GET api/v1/chatrooms
            r.get do
              response.status = 200
              output = { chatroom_ids: Chatroom.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/chatrooms
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
        end
      end
    end
  end
end
