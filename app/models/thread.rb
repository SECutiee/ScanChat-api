# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'
require 'time'
require 'sequel'

module ScanChat
  # represents a thread in the system
  class Thread < Sequel::Model
    one_to_many :messages
    plugin :association_dependencies, messages: :destroy

    # Polymorphic association
    one_to_one :messageboard, key: :threadable_id
    one_to_one :chatroom, key: :threadable_id

    # Plugins
    plugin :uuid, field: :id
    plugin :validation_helpers
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :name, :owner_id, :threadable_id, :threadable_type, :description, :expiration_date

    # Validations
    def validate
      super
      return if threadable_id_valid?

      errors.add(:threadable_id,
                 'must reference a threadable(chatroom/messageboard) that matches the threadable_type')
    end

    # Custom validation method to check threadable_type
    def threadable_id_valid?
      return true if threadable_id.nil? || threadable_id.empty?

      if threadable_type == 'chatroom'
        Chatroom.where(id: threadable_id).count.positive?
      else
        Messageboard.where(id: threadable_id).count.positive?
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
              name:,
              owner_id:,
              description:,
              expiration_date:
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
