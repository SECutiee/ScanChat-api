# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Message Handling' do
  before do
    wipe_database

    DATA[:chatrooms].each do |chatroom_data|
      Chats::Chatroom.create(chatroom_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    mes_data = DATA[:messages][1]
    chatr = Chats::Chatroom.first
    new_mes = chatr.add_message(mes_data)

    mes = Chats::Message.find(id: new_mes.id)
    _(mes.content).must_equal mes_data['content']
    _(mes.sender_id).must_equal mes_data['sender_id']
  end

  it 'SECURITY: should secure sensitive attributes' do
    mes_data = DATA[:messages][1]
    chatr = Chats::Chatroom.first
    new_mes = chatr.add_message(mes_data)
    stored_mes = app.DB[:messages].first

    _(stored_mes[:content_secure]).wont_equal new_mes.content
  end
end
