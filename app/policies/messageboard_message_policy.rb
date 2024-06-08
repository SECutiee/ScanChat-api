# frozen_string_literal: true

# Policy to determine if account can view a project
# Check whether the current account has permission to view, edit or delete a file. Specific permission checks are based on whether the account is the owner or collaborator of the project to which the file belongs.
class MessageboardMessagePolicy
  def initialize(account, message)
    @account = account
    @message = message
  end

  # def can_view?
  #   account_owns_messageboard? || account_joins_in_messageboard?
  # end

  def can_edit?
    messageboardmessage_belongs_to_account?
  end

  def can_delete?
    messageboardmessage_belongs_to_account?
  end

  def summary
    {
      # can_view: can_view?,
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end

  private

  # def account_owns_messageboard?
  #   @message.thread.owner== @account
  # end

  # def account_joins_in_messageboard? # Check if the account is a members on the messageboard the message belongs to.
  #   @message.thread.messageboard.members.include?(@account) #Wilmacheck: .thread.messageboard.members
  # end

  def messageboardmessage_belongs_to_account?
    @message.sender == @account #Wilmacheck
  end

end
