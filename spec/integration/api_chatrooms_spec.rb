# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test chatrooms Handling' do ###
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:threads].each do |thread_data|
      ScanChat::Thread.create(thread_data)
    end
  end

  describe 'Getting chatrooms' do ###
    it 'HAPPY: should be able to get list of all chatrooms' do ###
      ScanChat::Thread.create(DATA[:threads][0]) ### ask
      ScanChat::Thread.create(DATA[:threads][1]) ### ask

      get 'api/v1/chatrooms' ### ask should it be sth like => api/v1/threads/chatrooms ??
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single chatroom' do
      existing_thre = DATA[:chatrooms][1]
      ScanChat::Chatroom.create(existing_thre)
      id = ScanChat::Chatroom.first.id

      get "/api/v1/chatrooms/#{id}" ### ask same Q in line 17
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data']['attributes']['id']).must_equal id
      _(result['data']['attributes']['name']).must_equal existing_thre['name'] ### ask
    end

    it 'SAD: should return error if unknown chatroom requested' do ###
      get '/api/v1/chatrooms/foobar' ### ask

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      ScanChat::Thread.create(name: 'New Chatroom', thread_type: 'chatroom') ###
      ScanChat::Thread.create(name: 'Newer Chatroom', thread_type: 'chatroom') ###
      get 'api/v1/chatrooms/2%20or%20id%3E0' ### ask

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Chatrooms' do ###
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @thre_data = DATA[:threads][1] ### ask
    end

    it 'HAPPY: should be able to create new chatrooms' do ###
      post 'api/v1/chatrooms', @thre_data.to_json, @req_header ### ask thre_data
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      thre = ScanChat::Thread.first ###

      _(created['id']).must_equal thre.id ###
      _(created['name']).must_equal @thre_data['name'] ### ask
      _(created['description']).must_equal @thre_data['description'] ### ask
    end

    it 'SECURITY: should not create chatroom with mass assignment' do ###
      bad_data = @thre_data.clone ###
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/chatrooms', bad_data.to_json, @req_header ###

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
