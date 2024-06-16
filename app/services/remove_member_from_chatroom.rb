# frozen_string_literal: true

module ScanChat
  # Remove a member from a chatroom
  class RemoveMemberFromChatroom
    # Error for cannot remove member
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove that person'
      end
    end

    def self.call(auth:, member_username:, chatroom_id:)
      chatroom = Chatroom.first(thread_id: chatroom_id)
      member = Account.first(username: member_username)

      policy = ChatroomJoinRequestPolicy.new(chatroom, auth[:account], member, auth[:scope])
      raise ForbiddenError unless policy.can_remove?

      chatroom.remove_member(member)
      member
    end
  end
end
