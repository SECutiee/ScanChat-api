# frozen_string_literal: true

module ScanChat
  # Create new configuration for a thread
  class CreateMessageboardForOwner
    # Error for  cannot add messages
    class ForbiddenError < StandardError
      def message
        'You are not allowed to create chatrooms'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot create a chatroom with those attributes'
      end
    end

    def self.call(account:, messageboard_data:)
      create_messageboard(account.id, messageboard_data)
    end

    def self.create_messageboard(owner_id, msgb_data)
      is_anonymous = msgb_data.delete('is_anonymous')
      msgb_data.delete('owner_username') unless msgb_data['owner_username'].nil?
      msgb_data['thread_type'] = 'messageboard'
      new_thread = ScanChat::Thread.create(msgb_data)
      # Api.logger.info('new_thread')
      %w[name description thread_type].each do |info|
        msgb_data.delete(info)
      end
      msgb_data['is_anonymous'] = is_anonymous == 'true'
      # Api.logger.info("new_chatroom:#{msgb_data}")
      new_messageboard = ScanChat::Messageboard.create(msgb_data)
      # Api.logger.info('new_chatroom')
      new_messageboard.thread = new_thread
      new_messageboard.save
      Account.find(id: owner_id)
             .add_owned_thread(new_thread)
      new_thread.messageboard
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
