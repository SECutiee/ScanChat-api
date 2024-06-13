# frozen_string_literal: true

module ScanChat
  # Policy to determine if an account can view a particular project
  # Check the various operation permissions of the current account on a certain chatroom, depending on whether the account is the owner or members of the chatroom.
  class ChatroomPolicy
    def initialize(account, chatroom)
      @account = account
      @chatroom = chatroom
    end

    def can_view?
      account_is_owner? || (chatroom_is_not_expired? && account_is_member?)
    end

    # duplication is ok!
    def can_edit?
      chatroom_is_not_expired? && account_is_owner?
    end

    def can_delete?
      chatroom_is_not_expired? && account_is_owner?
    end

    def can_leave?
      chatroom_is_not_expired? && account_is_member?
    end

    def can_add_messages?
      chatroom_is_not_expired? && (account_is_owner? || account_is_member?)
    end

    def can_delete_messages?
      chatroom_is_not_expired? && (account_is_owner? || account_is_member?)
    end

    def can_add_members?
      chatroom_is_not_expired? && account_is_owner?
    end

    def can_remove_members?
      chatroom_is_not_expired? && account_is_owner?
    end

    def can_join?
      chatroom_is_not_expired? && !(account_is_owner? || account_is_member?)
    end

    def summary # rubocop:disable Metrics/MethodLength
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_leave: can_leave?,
        can_add_messages: can_add_messages?,
        can_delete_messages: can_delete_messages?,
        can_add_members: can_add_members?,
        can_remove_members: can_remove_members?,
        can_join: can_join?
      }
    end

    private

    def account_is_owner?
      @chatroom.thread.owner == @account
    end

    def account_is_member?
      @chatroom.members.include?(@account)
    end

    def chatroom_is_not_expired?
      Api.logger.info("chatroom_is_not_expired? #{@chatroom} #{@chatroom.expiration_date.nil? || @chatroom.expiration_date > Time.now}")
      @chatroom.expiration_date.nil? || @chatroom.expiration_date > Time.now
    end
  end
end
