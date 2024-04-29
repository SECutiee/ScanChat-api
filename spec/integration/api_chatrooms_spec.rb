# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Chatroom Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Getting Chatrooms' do
    it 'HAPPY: should be able to get a list of all chatrooms' do
      Chats::Chatroom.create(DATA[:chatrooms][0]).save
      Chats::Chatroom.create(DATA[:chatrooms][1]).save

      get 'api/v1/chatrooms'
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single chatroom' do
      @chatr_data = DATA[:chatrooms][0]
      Chats::Chatroom.create(@chatr_data).save
      id = Chats::Chatroom.first.id

      get "/api/v1/chatrooms/#{id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data']['attributes']['id']).must_equal id
      _(result['data']['attributes']['name']).must_equal @chatr_data['name']
    end

    it 'SAD: should return error if unknown chatroom requested' do
      get '/api/v1/chatrooms/foobar'

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      Chats::Chatroom.create(name: 'New Chatroom')
      Chats::Chatroom.create(name: 'Newer Chatroom')
      get 'api/v1/chatroom/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Chatrooms' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @chatr_data = DATA[:chatrooms][0]
    end

    it 'HAPPY: should be able to create a new chatroom' do
      post 'api/v1/chatrooms', @chatr_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      chatr = Chats::Chatroom.first

      _(created['id']).must_equal chatr.id
      _(created['name']).must_equal @chatr_data['name']
      _(created['members']).must_equal @chatr_data['members']
    end

    it 'SECURITY: should not create chatroom with mass assignment' do
      bad_data = @chatr_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/chatrooms', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
