# frozen_string_literal: true

module ScanChat
  # Create new configuration for a thread
  class CreateChatroomForOwner
    def self.call(owner_id:, name:, is_private:)
      new_thread = ScanChat::Thread.create(name:, thread_type: 'chatroom')
      new_chatroom = ScanChat::Chatroom.create(is_private:)
      new_chatroom.thread = new_thread
      new_chatroom.save
      Account.find(id: owner_id)
             .add_owned_thread(new_thread)
      new_thread.chatroom
    end
  end
end
