# frozen_string_literal: true

module ScanChat
  # Create new configuration for a thread
  class AddMessageToThread
    def self.call(thread_id:, content:, sender_id:)
      Thread.first(id: thread_id)
            .add_message(content:, sender_id:)
    end
  end
end
