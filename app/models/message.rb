# frozen_string_literal: true

require 'json'
require 'sequel'
require 'base64'
require 'rbnacl'
require 'time'

module ScanChat
  # Represents a message of a thread
  class Message < Sequel::Model
    many_to_one :thread
    many_to_one :sender, class: :'ScanChat::Account'

    plugin :timestamps
    plugin :whitelist_security

    set_allowed_columns :content, :sender_id

    # Secure getters and setters

    def content
      SecureDB.decrypt(content_secure)
    end

    def content=(plaintext)
      self.content_secure = SecureDB.encrypt(plaintext)
    end

    def get_thread_members # Wilmacheck: there must be a more clever way to write it
      if thread.chatroom
        thread.chatroom.members
      elsif thread.messageboard
        thread.messageboard.members
      else
        []
      end
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'message',
          attributes: {
            id:,
            content:,
            sender_username: sender.username,
            sender_nickname: sender.nickname,
            sender_id: sender.id
          }
          # include: {
          #   thread:
          # }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
