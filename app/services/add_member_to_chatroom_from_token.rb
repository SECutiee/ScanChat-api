# frozen_string_literal: true

module ScanChat
  # Add a member to another owner's existing chatroom
  class AddMemberToChatroomFromToken
    # Error for owner cannot be member
    class ForbiddenError < StandardError
      def message
        'You are not allowed to invite that person as member'
      end
    end

    def self.call(auth:, chatroom:, invite_token:)
      Api.logger.info("add_member: invite_token: #{invite_token}")
      inviter_id = QRToken.new(invite_token).token_creator_id
      Api.logger.info("inviter_id: #{inviter_id}")
      Api.logger.info("chatroom: #{chatroom.thread.id}")
      inviter = Account.first(id: inviter_id)
      Api.logger.info("inviter: #{inviter}")
      invited = Account.first(id: auth[:account].id)
      policy = ChatroomJoinRequestPolicy.new(
        chatroom, auth[:account], invitee, auth[:scope]
      )
      Api.logger.info("policy: #{policy}")
      raise ForbiddenError unless policy.can_invite?

      chatroom.add_member(invited)
      invited
    end
  end
end
