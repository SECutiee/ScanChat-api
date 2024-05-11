# frozen_string_literal: true

module ScanChat
  # Service object to create a new thread for an owner
  class CreateThreadForOwner
    def self.call(owner_id:, thread_data:)
      Account.find(id: owner_id)
             .add_owned_thread(thread_data)
    end
  end
end
