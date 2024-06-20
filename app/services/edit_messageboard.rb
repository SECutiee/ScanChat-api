# frozen_string_literal: true

module ScanChat
  # Add a message to messageboard
  class EditMessageboard
    # Error for  cannot add messages
    class ForbiddenError < StandardError
      def message
        'You are not allowed to edit the messageboard'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot edit a messageboard with those attributes'
      end
    end

    def self.call(auth:, messageboard:, messageboard_data:)
      policy = MessageboardPolicy.new(auth[:account], messageboard, auth[:scope])
      raise ForbiddenError unless policy.can_add_messages?

      edit_messageboard(messageboard, messageboard_data)
    end

    def self.edit_messageboard(messageboard, messageboard_data)
      Api.logger.info("messageboard_data: #{messageboard_data}")
      messageboard.thread.update(messageboard_data)
      Api.logger.info("edited_messageboard: #{messageboard.name} #{messageboard.description} #{messageboard.expiration_date} #{messageboard.is_private}")
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
