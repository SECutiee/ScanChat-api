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

    plugin :association_dependencies,
           thread: :destroy

    # methods to ensure that threads doesn't have to be called directly in code

    def add_message(message_data)
      thread.add_message(message_data)
    end

    def messages
      thread.messages
    end

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

    def name=(value)
      thread.name = value
      thread.save
    end

    def description=(value)
      thread.description = value
      thread.save
    end

    def expiration_date=(value)
      thread.expiration_date = value
      thread.save
    end

    def owner=(value)
      thread.owner = value
      thread.save
    end

    def to_h
      {
        type: 'messageboard',
        attributes: {
          id:,
          is_anonymous:,
          thread:,
          thread_id:
        }
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          owner:,
          messages:
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
