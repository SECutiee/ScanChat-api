# frozen_string_literal: true

module ScanChat
  # Policy to determine if account can view a project
  # AccountScope 類用於確定某個帳戶可以查看的項目範圍。如果當前帳戶是目標帳戶本人，則可以查看目標帳戶的所有項目；
  # 如果不是，則只能查看目標帳戶的項目中包含當前帳戶作為協作者的那些項目。
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
        account.owned_chatrooms + account.joined_chatrooms # Wilmacheck: joined_chatrooms
      end

      def includes_member?(chatroom, account)
        chatroom.members.include? account
      end
    end
  end
end
