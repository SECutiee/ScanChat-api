# frozen_string_literal: true

# Policy to determine if account can view a project
# Checks whether the current account has permission to view, edit or delete a file. Specific permission checks are based on whether the account is the owner or collaborator of the project to which the file belongs.
class ChatroomMessagePolicy
  def initialize(account, message)
    @account = account
    @message = message
  end

  def can_view?
    account_owns_chatroom? || account_joins_in_chatroom?
  end

  def can_edit?
    ( account_owns_chatroom? || account_joins_in_chatroom? ) && chatroommessage_belongs_to_account?
  end

  def can_delete?
    ( account_owns_chatroom? || account_joins_in_chatroom? ) && chatroommessage_belongs_to_account?
  end

  def summary
    {
      can_view: can_view?,
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end

  private

  def account_owns_chatroom?
    @message.thread.owner== @account
  end

  def account_joins_in_chatroom? # Check if the account is a members on the chatroom the message belongs to.
    @message.thread.chatroom.members.include?(@account) #Wilmacheck: .thread.chatroom.members
  end

  def chatroommessage_belongs_to_account?
    @message.sender == @account #Wilmacheck
  end
end
