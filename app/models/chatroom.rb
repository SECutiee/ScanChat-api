require 'json'
require 'base64'
require 'rbnacl'
require 'time'
require 'sequel'

module Chats
  # represents a chatroom in the system
  class Chatroom < Sequel::Model
    one_to_many :messages
    plugin :association_dependencies, messages: :destroy

    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'chatroom',
            attributes: {
              id:,
              name:,
              members:,
              message_count:,
              messages:
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
