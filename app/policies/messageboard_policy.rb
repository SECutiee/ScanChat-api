# frozen_string_literal: true

module ScanChat
  # Policy to determine if an account can view a particular project
  # Check the various operation permissions of the current account on a certain messageboard, depending on whether the account is the owner of the message.
  class MessageboardPolicy
    def initialize(account, messageboard)
      @account = account
      @messageboard = messageboard
    end

    def can_delete?
      account_is_owner?
    end

    def summary
      {
        can_delete: can_delete?
      }
    end

    private

    def account_is_owner?
      @messageboard.thread.owner == @account
    end
  end
end
