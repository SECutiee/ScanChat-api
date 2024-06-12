# frozen_string_literal: true

module ScanChat
  # Policy to determine if an account can view a particular chatroom
  # Check whether the current requester has permission to invite other accounts to become members on a chatroom or remove them
  class ChatroomJoinRequestPolicy
    def initialize(chatroom, requestor_account, target_account)
      @chatroom = chatroom
      @requestor_account = requestor_account
      @target_account = target_account
      @requestor = ChatroomPolicy.new(requestor_account, chatroom)
      @target = ChatroomPolicy.new(target_account, chatroom)
    end

    def can_invite?
      @requestor.can_add_members? && @target.can_join?
    end

    def can_remove?
      @requestor.can_remove_members? && target_is_members?
    end

    private

    def target_is_members?
      @chatroom.members.include?(@target_account)
    end
  end
end
