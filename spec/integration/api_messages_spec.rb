# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Message Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:threads].each do |thread_data|
      ScanChat::Thread.create(thread_data) # .save
    end
  end

  it 'HAPPY: should be able to get a list of all messages' do
    thread = ScanChat::Thread.first
    DATA[:messages].each do |message_data|
      thread.add_message(message_data)
    end

    get "api/v1/threads/#{thread.id}/messages"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal DATA[:messages].count
  end

  it 'HAPPY: should be able to get details of a single message' do
    mes_data = DATA[:messages][0]
    thread = ScanChat::Thread.first

    message = thread.add_message(mes_data)

    get "api/v1/threads/#{thread.id}/messages/#{message.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal message.id
    _(result['data']['attributes']['content']).must_equal mes_data['content']
    _(result['data']['attributes']['sender_id']).must_equal mes_data['sender_id']
  end

  it 'SAD: should return error if unknown message requested' do
    thread = ScanChat::Thread.first
    get "/api/v1/threads/#{thread.id}/messages/foobar"

    _(last_response.status).must_equal 404
  end

  describe 'Creating New Messages' do
    before do
      @thread = ScanChat::Thread.first
      @mes_data = DATA[:messages][1]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should b e able to create a new message' do
      post "/api/v1/threads/#{@thread.id}/messages", @mes_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      mes = ScanChat::Message.first

      _(created['id']).must_equal mes.id
      _(created['content']).must_equal @mes_data['content']
      _(created['sender_id']).must_equal @mes_data['sender_id']
    end

    it 'SECURITY: should not create messages with mass assignment' do
      bad_data = @mes_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/threads/#{@thread.id}/messages",
           bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
