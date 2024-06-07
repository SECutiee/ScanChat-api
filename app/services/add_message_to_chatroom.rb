# frozen_string_literal: true

module ScanChat
  # Add a message to chatroom
  class AddMessageToChatroom
    # Error for  cannot add messages
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

    def self.call(account:, chatroom:, message_data:)
      policy = ChatroomPolicy.new(account, chatroom)
      raise ForbiddenError unless policy.can_add_messages?

      add_message(chatroom, message_data)
    end

    def self.add_message(chatroom, message_data)
      chatroom.add_message(message_data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
