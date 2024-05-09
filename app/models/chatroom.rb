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
    # plugin :uuid, field: :thread_id
    plugin :association_dependencies, thread: :destroy
    plugin :validation_helpers
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :members, :is_private, :link_expiration, :thread_id

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
