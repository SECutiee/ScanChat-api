# frozen_string_literal: true

module ScanChat
  # Create new configuration for a project
  class CreateMessageboardForOwner
    def self.call(owner_id:, name:, is_anonymous:)
      new_thread = ScanChat::Thread.create(name:, thread_type: 'messageboard')
      new_messageboard = ScanChat::Messageboard.create(is_anonymous:)
      new_messageboard.thread = new_thread
      new_messageboard.save
      Account.find(id: owner_id)
             .add_owned_thread(new_thread)
      new_thread.messageboard
    end
  end
end
