# frozen_string_literal: true

module ScanChat
  # Create new chatroom for an owner
  class CreateChatroomForOwner
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

    def self.call(account:, chatroom_data:)
      # TODO: add policy check here, maybe also needs new policy
      # policy = ChatroomPolicy.new(account, chatroom)
      # raise ForbiddenError unless policy.can_add_messages?
      create_chatroom(account.id, chatroom_data)
    end

    def self.create_chatroom(owner_id, chatroom_data)
      # name = chatroom_data['name']
      # is_private = chatroom_data['is_private']
      # description = chatroom_data['description']
      # expiration_date = chatroom_data['expiration_date']
      # Api.logger.info("chatroom_data #{chatroom_data}")
      is_private = chatroom_data.delete('is_private')
      chatroom_data['thread_type'] = 'chatroom'
      new_thread = ScanChat::Thread.create(chatroom_data)
      # Api.logger.info('new_thread')
      %w[name description expiration_date thread_type].each do |info|
        chatroom_data.delete(info)
      end
      chatroom_data['is_private'] = is_private == 'true'
      # Api.logger.info("new_chatroom:#{chatroom_data}")
      new_chatroom = ScanChat::Chatroom.create(chatroom_data)
      # Api.logger.info('new_chatroom')
      new_chatroom.thread = new_thread
      new_chatroom.save
      Account.find(id: owner_id)
             .add_owned_thread(new_thread)
      new_thread.chatroom
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
