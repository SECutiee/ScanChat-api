# frozen_string_literal: true

module ScanChat
  # Policy to determine if an account can view a particular chatroom
  # Check whether the current requester has permission to invite other accounts to become members on a chatroom or remove them
  class ChatroomJoinRequestPolicy
    def initialize(chatroom, requestor_account, target_account, auth_scope = nil)
      @chatroom = chatroom
      @requestor_account = requestor_account
      @target_account = target_account
      @auth_scope = auth_scope
      @requestor = ChatroomPolicy.new(requestor_account, chatroom, auth_scope)
      @target = ChatroomPolicy.new(target_account, chatroom, auth_scope)
    end

    def can_invite?
      # can_write? &&
      @requestor.can_add_members? && @target.can_join?
    end

    def can_remove?
      can_write? &&
        @requestor.can_remove_members? && target_is_members?
    end

    def can_write?
      @auth_scope ? @auth_scope.can_write?('chatrooms') : false
    end

    private

    def target_is_members?
      @chatroom.members.include?(@target_account)
    end
  end
end
