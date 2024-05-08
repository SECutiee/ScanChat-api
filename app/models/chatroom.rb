# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'
require 'time'
require 'sequel'

module ScanChat
  # represents a thread in the system
  class Chatroom < Sequel::Model
    # Association to Thread
    many_to_one :thread

    # Plugins
    plugin :uuid, field: :thread_id
    plugin :association_dependencies, thread: :destroy
    plugin :validation_helpers
    plugin :uuid, field: :id
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :members, :is_private, :link_expiration, :thread_id

    # Secure getters and setters

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'chatroom',
            attributes: {
              id:,
              members:,
              is_private:,
              link_expiration:
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
