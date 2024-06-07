# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddMember service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      ScanChat::Account.create(account_data)
    end

    chatroom_data = DATA[:chatrooms].first

    @owner = ScanChat::Account.all[0]
    @member = ScanChat::Account.all[1]
    @chatroom = ScanChat::CreateProjectForOwner.call(
      owner_id: @owner.id, chatroom_data:
    )
  end

  it 'HAPPY: should be able to add a member to a chatroom' do
    ScanChat::AddMember.call(
      account: @owner,
      chatroom: @chatroom,
      collab_email: @member.email
    )

    _(@member.chatrooms.count).must_equal 1
    _(@member.chatrooms.first).must_equal @chatroom
  end

  it 'BAD: should not add owner as a member' do
    _(proc {
      ScanChat::AddMember.call(
        account: @owner,
        chatroom: @chatroom,
        collab_email: @owner.email
      )
    }).must_raise ScanChat::AddMember::ForbiddenError
  end
end
