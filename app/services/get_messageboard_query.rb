# frozen_string_literal: true

module ScanChat
  # check if account is allowed to see messageboard details
  class GetMessageboardQuery
    # Error for not allowed to access messageboard
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that messageboard'
      end
    end

    # Error for cannot find a messageboard
    class NotFoundError < StandardError
      def message
        'We could not find that messageboard'
      end
    end

    def self.call(account:, messageboard:)
      raise NotFoundError unless messageboard

      policy = MessageboardPolicy.new(account, messageboard)
      raise ForbiddenError unless policy.can_view?

      messageboard.full_details.merge(policies: policy.summary)
    end
  end
end
