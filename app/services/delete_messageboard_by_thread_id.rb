# frozen_string_literal: true

module ScanChat
  # Create new configuration for a thread
  class DeleteMessageboardByThreadId
    def self.call(thread_id:)
      messageboard = ScanChat::Thread.find(id: thread_id).messageboard
      messageboard.destroy
    end
  end
end
