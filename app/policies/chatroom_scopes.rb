# frozen_string_literal: true

module ScanChat
  # Policy to determine if account can view a project
  # The AccountScope class is used to determine the scope of chatrooms that an account can view.
  # If the current account is the target account, you can view all items of the target account;
  # If not, you can only view those chatrooms among the target account's chatrooms that have the current account as a members.
  class ChatroomPolicy
    # Scope of chatroom policies
    class AccountScope
      def initialize(current_account)
        target_account ||= current_account
        @full_scope = all_chatrooms(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        @full_scope.select do |chatr|
          owner?(chatr, @current_account) || not_expired?(chatr)
        end
      end

      private

      def all_chatrooms(account)
        account.owned_chatrooms + account.joined_chatrooms
      end

      # def includes_member?(chatroom, account)
      #   chatroom.members.include?(account)
      # end

      def owner?(chatroom, account)
        chatroom.owner == account
      end

      def not_expired?(chatroom)
        # Api.logger.info("chatroom_is_not_expired? #{chatroom} #{chatroom.expiration_date.nil? || chatroom.expiration_date > Time.now}")
        chatroom.expiration_date.nil? || chatroom.expiration_date > Time.now
      end
    end
  end
end
