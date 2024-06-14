# frozen_string_literal: true

module ScanChat
  # Add a message to messageboard
  class AddMessageToMessageboard
    # Error for cannot add messages
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add a message'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot add a message with those attributes'
      end
    end

    def self.call(account:, messageboard:, message_data:)
      # policy = MessageboardPolicy.new(account, messageboard)
      # raise ForbiddenError unless policy.can_add_messages?

      msg_data = {}
      msg_data['content'] = message_data['content']
      msg_data['sender_id'] = account.id
      add_message(messageboard, msg_data)
    end

    def self.add_message(messageboard, message_data)
      messageboard.add_message(message_data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
