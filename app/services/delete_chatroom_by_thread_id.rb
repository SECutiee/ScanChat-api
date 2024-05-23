# frozen_string_literal: true

module ScanChat
  # Create new configuration for a thread
  class DeleteChatroomByThreadId
    def self.call(thread_id:)
      chatroom = ScanChat::Thread.find(id: thread_id).chatroom
      chatroom.destroy
    end
  end
end
