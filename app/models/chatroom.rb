# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'
require 'time'
require 'sequel'

module ScanChat
  # represents a thread in the system
  class Chatroom < Sequel::Model
    one_to_one :thread
    plugin :association_dependencies, thread: :destroy

    plugin :uuid, field: :id
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :members, :is_private, :link_expiration

    # Secure getters and setters
    def name
      SecureDB.decrypt(name_secure)
    end

    def name=(plaintext)
      self.name_secure = SecureDB.encrypt(plaintext)
    end

    def description
      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'thread',
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
