# check expiration of the token
# get the chatroom object from thread id
# check if the creator_id account can actually invite or not (policies)
# return the chatroom object if everything ok, otherwise throw error/ return nil
# frozen_string_literal: true

module ScanChat
  # check if auth is allowed to see chatroom details
  class GetChatroomFromInviteToken
    # Error for not allowed to access chatroom
    class TokenExpiredError < StandardError
      def message
        'The token is expired'
      end
    end

    # Error for cannot find a chatroom
    class NotFoundError < StandardError
      def message
        'We could not find that chatroom'
      end
    end

    def self.call(invite_token:)
      raise NotFoundError unless invite_token

      Api.logger.info("invite_token: #{invite_token}")
      token = QRToken.new(invite_token)
      raise TokenExpiredError if token.expired?

      # need policy here? (@ju)
      chatroom = Chatroom.find(thread_id: token.thread_id)
      chatroom.to_h
    end
  end
end
