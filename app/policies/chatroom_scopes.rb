# frozen_string_literal: true

module ScanChat
  # Policy to determine if account can view a project
  # The AccountScope class is used to determine the scope of chatrooms that an account can view. If the current account is the target account, you can view all items of the target account;
  # If not, you can only view those chatrooms among the target account's chatrooms that have the current account as a members.
  class ChatroomPolicy
    # Scope of chatroom policies
    class AccountScope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_chatrooms(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        if @current_account == @target_account
          @full_scope
        else
          @full_scope.select do |chatr|
            includes_member?(chatr, @current_account)
          end
        end
      end

      private

      def all_chatrooms(account)
        account.owned_chatrooms + account.joined_chatrooms
      end

      def includes_member?(chatroom, account)
        chatroom.members.include? account
      end
    end
  end
end
