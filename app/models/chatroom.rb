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
    one_to_one :thread, key: :thread_id, conditions: { threadable_type: 'chatroom' }

    # Plugins
    plugin :association_dependencies, thread: :destroy
    plugin :validation_helpers
    plugin :uuid, field: :id
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :members, :is_private, :link_expiration, :thread_id

    # Validations
    def validate
      super
      errors.add(:thread_id, 'must reference a Thread with threadable_type of chatroom') unless thread_id_valid?
    end

    # Custom validation method to check threadable_type
    def thread_id_valid?
      Thread.where(id: thread_id, threadable_type: 'chatroom').count.positive?
    end

    # Secure getters and setters

    # Instantiate associated thread object when assigning thread_id
    def thread_id=(id)
      @my_thread = Thread[id:]
      super(id)
    end

    def my_thread
      @my_thread ||= Thread[id: thread_id]
    end

    # getters and setters inherited from Thread

    def owner_id
      @my_thread.owner_id
    end

    def owner_id=(new_owner_id)
      @my_thread.owner_id = new_owner_id
    end

    def name
      @my_thread.name
    end

    def name=(new_name)
      @my_thread.name = new_name
    end

    def description
      @my_thread.name
    end

    def description=(new_description)
      @my_thread.description = new_description
    end

    # overwrite functions so they are also executed on the associated thread (my_thread)

    def save
      @my_thread.save
      super
    end

    def reload
      @my_thread.reload
      super
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
