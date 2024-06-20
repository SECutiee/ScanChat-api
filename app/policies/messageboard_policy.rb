# frozen_string_literal: true

module ScanChat
  # Policy to determine if an account can view a particular project
  # Check the various operation permissions of the current account on a certain messageboard, depending on whether the account is the owner of the message.
  class MessageboardPolicy
    def initialize(account, messageboard, _auth_scope = nil)
      @account = account
      @messageboard = messageboard
    end

    def can_delete?
      account_is_owner?
    end

    def can_view?
      messageboard_is_not_expired? || account_is_owner?
    end

    def can_edit?
      messageboard_is_not_expired? && account_is_owner?
    end

    def can_add_messages?
      messageboard_is_not_expired?
    end

    def summary
      {
        can_delete: can_delete?,
        can_view: can_view?,
        can_add_messages: can_add_messages?,
        can_edit: can_edit?
      }
    end

    private

    def account_is_owner?
      @messageboard.thread.owner == @account
    end

    def messageboard_is_not_expired?
      # Api.logger.info("messageboard_is_not_expired? #{@messageboard} #{@messageboard.expiration_date.nil? || @messageboard.expiration_date > Time.now}")
      # Api.logger.info("messageboard_is_not_expired? #{@messageboard} #{@messageboard.expiration_date.nil? || @messageboard.expiration_date > Time.now}")
      @messageboard.expiration_date.nil? || @messageboard.expiration_date > Time.now
    end
  end
end
