# frozen_string_literal: true

module Credence
  # Create new configuration for a thread
  class CreateMessageForThread
    def self.call(thread_id:, message_data:)
      Thread.first(id: thread_id)
            .add_message(message_data)
    end
  end
end
