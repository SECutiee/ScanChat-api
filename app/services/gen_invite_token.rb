# frozen_string_literal: true

module ScanChat
  # Create new chatroom for an owner
  class GenInviteToken
    # Error for cannot gen invite token
    class NoPermissionsError < StandardError
      def message
        'You are not allowed to create chatrooms'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot creata an invite token with those attributes'
      end
    end

    def self.call(thread_id:, auth:, action: 'join')
      chatroom = Chatroom.first(thread_id:)
      policy = ChatroomPolicy.new(auth[:account], chatroom, auth[:scope])
      raise NoPermissionsError unless policy.can_invite?

      generate_invite_token(thread_id, auth[:account].id, action)
    end

    def self.generate_invite_token(thread_id, token_creator_id, action)
      QRToken.create(action, thread_id, token_creator_id)
    end
  end
end
