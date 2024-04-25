# frozen_string_literal: true

require 'json'
require 'sequel'
require 'base64'
require 'rbnacl'
require 'time'

module Chats
  # Represents a message of a chatroom
  class Message < Sequel::Model
    many_to_one :chatroom

    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'message',
            attributes: {
              id:,
              content:,
              sender_id:
            }
          },
          included: {
            chatroom:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
