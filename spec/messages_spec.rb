# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Test Message Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:chatrooms].each do |chatroom_data|
      Chats::Chatroom.create(chatroom_data) # .save
    end
  end

  it 'HAPPY: should be able to get a list of all messages' do
    chatr = Chats::Chatroom.first
    DATA[:messages].each do |message_data|
      chatr.add_message(message_data)
    end

    get "api/v1/chatrooms/#{chatr.id}/messages"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal DATA[:messages].count
  end

  it 'HAPPY: should be able to get details of a single message' do
    mes_data = DATA[:messages][0]
    chatr = Chats::Chatroom.first
    message = chatr.add_message(mes_data).save

    get "api/v1/chatrooms/#{chatr.id}/messages/#{message.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal message.id
    _(result['data']['attributes']['content']).must_equal mes_data['content']
    _(result['data']['attributes']['sender_id']).must_equal mes_data['sender_id']
  end

  it 'SAD: should return error if unknown message requested' do
    chatr = Chats::Chatroom.first
    get "/api/v1/chatrooms/#{chatr.id}/messages/foobar"

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create a new message' do
    chatr = Chats::Chatroom.first
    mes_data = DATA[:messages][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "/api/v1/chatrooms/#{chatr.id}/messages", mes_data.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.headers['Location']).must_match(%r{api/v1/chatrooms/\d+/messages/\d+})

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    mes = Chats::Message.first

    _(created['id']).must_equal mes.id
    _(created['content']).must_equal mes_data['content']
    _(created['sender_id']).must_equal mes_data['sender_id']
  end
end
