# frozen_string_literal: true

module ScanChat
  # Add a message to chatroom
  class EditChatroom
    # Error for  cannot add messages
    class ForbiddenError < StandardError
      def message
        'You are not allowed to edit the chatroom'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot edit a chatroom with those attributes'
      end
    end

    def self.call(account:, chatroom:, chatroom_data:)
      # policy = ChatroomPolicy.new(account, chatroom)
      # raise ForbiddenError unless policy.can_add_messages?
      # TODO add policy (@ju)

      # Api.logger.info("messagedata: #{message_data}")
      edit_chatroom(chatroom, chatroom_data)
    end

    def self.edit_chatroom(chatroom, chatroom_data)
      Api.logger.info("chatroom_data: #{chatroom_data}")
      chatroom.thread.update(chatroom_data)
      Api.logger.info("edited_chatroom: #{chatroom.name} #{chatroom.description} #{chatroom.expiration_date} #{chatroom.is_private}")
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
