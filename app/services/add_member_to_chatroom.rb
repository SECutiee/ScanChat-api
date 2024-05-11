# frozen_string_literal: true

module ScanChat
  # Add a member to another owner's existing chatroom of thread
  class AddMemberToChatroom
    # Error for owner cannot be member
    class OwnerNotMemberError < StandardError
      def message = 'Owner cannot be member of project'
    end

    def self.call(email:, chatroom_id:)
      member = Account.first(email:)
      chatroom = Chatroom.first(id: chatroom_id)
      raise(OwnerNotMemberError) if chatroom.thread.owner.id == member.id

      chatroom.add_member(member)
    end
  end
end

# # frozen_string_literal: true

# module ScanChat
#   # Create new configuration for a thread
#   class CreateChatroomForOwner
#     def self.call(owner_id:, name:, is_private:)
#       new_thread = ScanChat::Thread.create(name:, thread_type: 'chatroom')
#       new_chatroom = ScanChat::Chatroom.create(is_private:)
#       new_chatroom.thread = new_thread
#       new_chatroom.save
#       Account.find(id: owner_id)
#              .add_owned_thread(new_thread)
#       new_thread.chatroom
#     end
#   end
# end
