# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Message Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = ScanChat::Account.create(@account_data)
    @account.add_owned_chatroom(DATA[:chatrooms][0])
    @account.add_owned_chatroom(DATA[:chatrooms][1])
    ScanChat::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting a single message' do
    it 'HAPPY: should be able to get details of a single message' do
      msg_data = DATA[:chatrooms][0]
      chatr = @account.chatrooms.first
      msg = chatr.add_message(msg_data)

      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/chatrooms/#{msg.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal msg.id
      _(result['attributes']['content']).must_equal msg_data['content']
    end

    it 'SAD AUTHORIZATION: should not get details without authorization' do
      msg_data = DATA[:chatrooms][1]
      chatr = ScanChat::Chatroom.first
      msg = chatr.add_message(msg_data)

      get "/api/v1/chatrooms/#{msg.id}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'BAD AUTHORIZATION: should not get details with wrong authorization' do
      msg_data = DATA[:chatrooms][0]
      chatr = @account.chatrooms.first
      msg = chatr.add_message(msg_data)

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/chatrooms/#{msg.id}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'SAD: should return error if message does not exist' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/chatrooms/foobar'

      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating Messages' do
    before do
      @chatr = ScanChat::Chatroom.first
      @msg_data = DATA[:chatrooms][1]
    end

    it 'HAPPY: should be able to create when everything correct' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/chatrooms/#{@chatr.id}/chatrooms", @msg_data.to_json
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      msg = ScanChat::Chatroom.first

      _(created['id']).must_equal msg.id
      _(created['content']).must_equal @msg_data['content']
    end

    it 'BAD AUTHORIZATION: should not create with incorrect authorization' do
      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      post "api/v1/chatrooms/#{@chatr.id}/chatrooms", @msg_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.headers['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'SAD AUTHORIZATION: should not create without any authorization' do
      post "api/v1/chatrooms/#{@chatr.id}/chatrooms", @msg_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.headers['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'BAD VULNERABILITY: should not create with mass assignment' do
      bad_data = @msg_data.clone
      bad_data['created_at'] = '1900-01-01'
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/chatrooms/#{@chatr.id}/chatrooms", bad_data.to_json

      data = JSON.parse(last_response.body)['data']
      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
      _(data).must_be_nil
    end
  end
end
