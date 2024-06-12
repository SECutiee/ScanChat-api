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

    def self.call(req_username:, member_email:, chatroom_id:)
      account = Account.first(username: req_username)
      chatroom = Chatroom.first(id: chatroom_id)
      member = Account.first(email: member_email)

      policy = ChatroomJoinRequestPolicy.new(chatroom, account, member)
      raise ForbiddenError unless policy.can_remove?

      chatroom.remove_member(member)
      member
    end
  end
end
