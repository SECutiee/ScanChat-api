# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'
require 'time'
require 'sequel'

module ScanChat
  # represents a thread in the system
  class Chatroom < Sequel::Model
    # Associations
    many_to_one :thread
    many_to_many :members,
                 class: :'ScanChat::Account',
                 join_table: :accounts_chatrooms,
                 left_key: :chatroom_id, right_key: :member_id

    # Plugins
    plugin :uuid, field: :id
    plugin :association_dependencies, thread: :destroy
    plugin :validation_helpers
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :members, :is_private, :link_expiration, :thread_id

    # Method interface to access and modify properties of the associated thread
    def save
      super
      return unless thread

      thread.save
    end

    def add_message(message_data)
      thread.add_message(message_data)
    end

    def messages
      thread.messages
    end

    def name
      # thread.refresh # TODO: omit the refresh since performance is bad
      thread.name
    end

    def description
      # thread.refresh
      thread.description
    end

    def expiration_date
      # thread.refresh
      thread.expiration_date
    end

    def owner
      # thread.refresh
      thread.owner
    end

    def name=(value)
      thread.name = value
      # thread.save # potential performance implications
    end

    def description=(value)
      thread.description = value
      # thread.save
    end

    def expiration_date=(value)
      thread.expiration_date = value
      # thread.save
    end

    def owner=(value)
      thread.owner = value
      # thread.save
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'chatroom',
          attributes: {
            id:,
            members:,
            is_private:,
            link_expiration:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
