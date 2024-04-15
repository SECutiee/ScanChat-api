# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../models/chat'

module Chats
  # Web Controller for Chats API

  class API < Roda
    plugin :environments
    plugin :halt

    CHATROOM.setup

    route do |r|
      r.get '' do
        'Chats API v0.1'
      end

      r.on 'chatrooms' do
        r.get do
          r.is do
          end
        end
      end
    end
  end
end
