# frozen_string_literal: true

module Credence
  # check if account is allowed to see chatroom details
  class GetChatroomQuery
    # Error for not allowed to access chatroom
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that chatroom'
      end
    end

    # Error for cannot find a chatroom
    class NotFoundError < StandardError
      def message
        'We could not find that chatroom'
      end
    end

    def self.call(account:, chatroom:)
      raise NotFoundError unless chatroom

      policy = ChatroomPolicy.new(account, chatroom)
      raise ForbiddenError unless policy.can_view?

      chatroom.full_details.merge(policies: policy.summary)
    end
  end
end
