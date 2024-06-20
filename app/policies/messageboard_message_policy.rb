# frozen_string_literal: true

# Policy to determine if account can view a project
# Check whether the current account has permission to view, edit or delete a file. Specific permission checks are based on whether the account is the owner or collaborator of the project to which the file belongs.
class MessageboardMessagePolicy
  def initialize(account, message)
    @account = account
    @message = message
  end

  def can_edit?
    messageboardmessage_belongs_to_account?
  end

  def can_delete?
    messageboardmessage_belongs_to_account?
  end

  def summary
    {
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end

  private

  # the message should belongs to messageboard (not chatroom) and also the sender of message should = @account
  def messageboardmessage_belongs_to_account?
    @message.thread.messageboard && @message.sender == @account
  end
end
