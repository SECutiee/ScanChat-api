# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative 'password'

module ScanChat
  # Models a registered account
  class Account < Sequel::Model
    one_to_many :owned_threads, class: :'ScanChat::Thread', key: :owner_id
    one_to_many :sent_messages, class: :'ScanChat::Message', key: :sender_id
    many_to_many :joined_chatrooms,
                 class: :'ScanChat::Chatroom',
                 join_table: :accounts_chatrooms,
                 left_key: :member_id, right_key: :chatroom_id

    plugin :association_dependencies,
           owned_threads: :destroy
    #  collaborations: :nullify TODO: what to do with messages when user is deleted?
    plugin :uuid, field: :id
    plugin :whitelist_security
    set_allowed_columns :username, :nickname, :image, :email, :password

    plugin :timestamps, update_on_create: true

    def self.create_github_account(github_account)
      create(username: github_account[:username],
             email: github_account[:email])
    end

    # helper functions for relationship to chatrooms/messageboards
    def owned_chatrooms
      owned_threads.select { |thread| thread.thread_type == 'chatroom' }.map(&:chatroom)
    end

    def owned_messageboards
      owned_threads.select { |thread| thread.thread_type == 'messageboard' }.map(&:messageboard)
    end

    def left_messages_messageboards
      sent_messages.select { |message| message.thread.thread_type == 'messageboard' }.map(&:thread).map(&:messageboard)
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      password = ScanChat::Password.from_digest(password_digest)
      password.correct?(try_password)
    end

    def to_json(options = {})
      JSON(
        {
          type: 'account',
          attributes: {
            username:,
            nickname:,
            image:,
            email:
          }
        }, options
      )
    end
  end
end
