# check expiration of the token
# get the messageboard object from thread id
# check if the creator_id account can actually invite or not (policies)
# return the messageboard object if everything ok, otherwise throw error/ return nil
# frozen_string_literal: true

module ScanChat
    # check if auth is allowed to see messageboard details
    class GetMessageboardFromInviteToken
      # Error for not allowed to access messageboard
      class TokenExpiredError < StandardError
        def message
          'The token is expired'
        end
      end
  
      # Error for cannot find a messageboard
      class NotFoundError < StandardError
        def message
          'We could not find that messageboard'
        end
      end
  
      def self.call(invite_token:)
        raise NotFoundError unless invite_token
  
        Api.logger.info("invite_token: #{invite_token}")
        token = QRToken.new(invite_token)
        raise TokenExpiredError if token.expired?
  
        # need policy here? (@ju)
        messageboard = messageboard.find(thread_id: token.thread_id)
        messageboard.to_h
      end
    end
  end
  