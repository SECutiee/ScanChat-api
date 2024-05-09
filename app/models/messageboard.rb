# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'
require 'time'
require 'sequel'

module ScanChat
  # represents a thread in the system
  class Messageboard < Sequel::Model
    # Association to Thread
    many_to_one :thread

    # Plugins
    plugin :uuid, field: :thread_id
    plugin :association_dependencies, thread: :destroy
    plugin :validation_helpers
    plugin :uuid, field: :id
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :is_anonymous, :thread_id

    # getters and setters for data elements of threads
    def name
      thread.name
    end

    def description
      thread.description
    end

    def expiration_date
      thread.expiration_date
    end

    def owner
      thread.owner
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'messageboard',
            attributes: {
              id:,
              is_anonymous:
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
