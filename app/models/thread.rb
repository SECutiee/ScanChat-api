# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'
require 'time'
require 'sequel'

module ScanChat
  # represents a thread in the system
  class Thread < Sequel::Model
    # Associations
    many_to_one :owner, class: :'ScanChat::Account'
    one_to_one :messageboard
    one_to_one :chatroom

    one_to_many :messages
    plugin :association_dependencies, messages: :destroy

    # Plugins
    plugin :uuid, field: :id
    plugin :validation_helpers
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :name, :thread_type, :description, :expiration_date

    # Validations
    def validate
      super
      return if thread_type_valid?

      errors.add('must reference a single chatroom/messageboard that matches the thread_type')
    end

    # Custom validation method to check thread_type
    def thread_type_valid?
      return false if messageboard && chatroom
      return true if messageboard.nil? && chatroom.nil?

      if thread_type == 'messageboard'
        chatroom.nil?
      else
        messageboard.nil?
      end
    end

    # Secure getters and setters
    def name
      SecureDB.decrypt(name_secure)
    end

    def name=(plaintext)
      self.name_secure = SecureDB.encrypt(plaintext)
    end

    def description
      return '' if description_secure == ''

      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'thread',
          attributes: {
            id:,
            name:,
            owner:,
            description:,
            messages:,
            expiration_date:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
