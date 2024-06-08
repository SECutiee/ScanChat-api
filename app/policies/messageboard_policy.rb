# frozen_string_literal: true

module ScanChat
  # Policy to determine if an account can view a particular project
  # 檢查當前帳戶對某個項目的各種操作權限，根據帳戶是否是項目的擁有者或協作者來決定。
  class MessageboardPolicy
    def initialize(account, messageboard)
      @account = account
      @messageboard = messageboard
    end

    # def can_view?
    #   account_is_owner? || account_is_member?
    # end

    # duplication is ok!
    # def can_edit?
    #   account_is_owner? || account_is_member?
    # end

    def can_delete?
      account_is_owner?
    end

    # def can_leave? # Wilmacheck: bc there is no member so we don't need the function of "leave"
    #   account_is_member?
    # end

    # def can_add_messages?
    #   account_is_owner? || account_is_member?
    # end

    # def can_remove_messages?
    #   account_is_owner? || account_is_member?
    # end

    # def can_add_members?
    #   account_is_owner?
    # end

    # def can_remove_members?
    #   account_is_owner?
    # end

    # def can_join?
    #   not (account_is_owner? or account_is_member?)
    # end

    def summary
      {
        # can_view: can_view?,
        # can_edit: can_edit?,
        can_delete: can_delete?
        # can_leave: can_leave?,
        # can_add_messages: can_add_messages?,
        # can_delete_messages: can_remove_messages?
        # can_add_members: can_add_members?,
        # can_remove_members: can_remove_members?,
        # can_join: can_join?
      }
    end

    private

    def account_is_owner?
      @messageboard.thread.owner == @account
    end

    # def account_is_member?
    #   @messageboard.members.include?(@account)
    # end
  end

end
