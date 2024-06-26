# frozen_string_literal: true

module ScanChat
  # Policy to determine if account can view a project
  # The AccountScope class is used to determine the scope of projects that an account can view. If the current account is the target account, you can view all items of the target account;
  # If not, you can only view those projects among the target account's projects that have the current account as a collaborator.
  class MessageboardPolicy
    # Scope of messageboard policies
    class AccountScope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_messageboards(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        return unless @current_account == @target_account

        @full_scope
      end

      private

      def all_messageboards(account)
        (account.owned_messageboards | account.left_messages_messageboards).uniq
      end
    end
  end
end
