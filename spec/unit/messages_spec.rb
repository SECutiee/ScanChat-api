# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Message Handling' do
  before do
    wipe_database
    create_accounts(DATA[:accounts])
    create_owned_chatrooms(DATA[:accounts], DATA[:chatrooms])
    create_owned_messageboards(DATA[:accounts], DATA[:messageboards])
  end

  it 'HAPPY: should retrieve correct data from database' do
    mes_data = DATA[:messages][0]
    cur_thread = ScanChat::Thread.all.find { |thread| thread.name == mes_data['thread_name'] }
    sender = ScanChat::Account.first(username: mes_data['sender_username'])
    new_mes = ScanChat::AddMessageToThread.call(thread_id: cur_thread.id, content: mes_data['content'],
                                                sender_id: sender.id)

    mes = ScanChat::Message.find(id: new_mes.id)
    _(mes.content).must_equal mes_data['content']
    _(mes.sender_id).must_equal sender.id.to_s
  end

  it 'SECURITY: should secure sensitive attributes' do
    mes_data = DATA[:messages][0]
    cur_thread = ScanChat::Thread.all.find { |thread| thread.name == mes_data['thread_name'] }
    sender = ScanChat::Account.first(username: mes_data['sender_username'])
    new_mes = ScanChat::AddMessageToThread.call(thread_id: cur_thread.id, content: mes_data['content'],
                                                sender_id: sender.id)
    stored_mes = app.DB[:messages].first

    _(stored_mes[:content_secure]).wont_equal new_mes.content
  end
end
