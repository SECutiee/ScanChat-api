require 'json'
require 'base64'
require 'rbnacl'
require 'time'
require 'sequel'

module Chats
  # Represents a message of a chatroom
  class Message < Sequel::Model
    many_to_one :chatroom

    plugin :timestamps

    def to_json(_options = {})
      JSON(
        {
          id: @id,
          content: @content,
          sender_id: @sender_id
          # timestamp: @timestamp
        }
      )
    end
  end
end
