# frozen_string_literal: true

module ScanChat
  # Delete Messageboard
  class DeleteMessageboardByThreadId
    def self.call(thread_id:)
      messageboard = ScanChat::Thread.find(id: thread_id).messageboard
      messageboard.destroy
    end
  end
end
