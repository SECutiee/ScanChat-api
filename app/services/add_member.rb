# frozen_string_literal: true

module ScanChat
  # Add a member to another owner's existing chatroom
  class AddMember
    # Error for owner cannot be member
    class ForbiddenError < StandardError
      def message
        'You are not allowed to invite that person as member'
      end
    end

    def self.call(account:, chatroom:, member_email:)
      invitee = Account.first(email: member_email)
      policy = ChatroomJoinRequestPolicy.new(chatroom, account, invitee)
      raise ForbiddenError unless policy.can_invite?

      chatroom.add_member(invitee)
      invitee
    end
  end
end
