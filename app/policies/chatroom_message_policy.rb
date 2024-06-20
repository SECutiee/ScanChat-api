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
    (account_owns_chatroom? || account_joins_in_chatroom?) && chatroommessage_belongs_to_account?
  end

  def can_delete?
    (account_owns_chatroom? || account_joins_in_chatroom?) && chatroommessage_belongs_to_account?
  end

  def summary
    {
      can_view: can_view?,
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end

  private

  # the message should belongs to chatroom (not messageboard) and also the owner of message should = @account
  def account_owns_chatroom?
    @message.thread.chatroom && @message.thread.chatroom.owner == @account
  end

  # Check if the account is a members on the chatroom the message belongs to.
  def account_joins_in_chatroom?
    @message.get_thread_members.include?(@account)
  end

  # the message should belongs to chatroom (not messageboard) and also the sender of message should = @account
  def chatroommessage_belongs_to_account?
    @message.thread.chatroom && @message.sender == @account
  end
end
