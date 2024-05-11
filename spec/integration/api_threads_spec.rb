# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Thread Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Getting Threads' do
    it 'HAPPY: should be able to get a list of all threads' do
      ScanChat::Thread.create(DATA[:threads][0]).save
      ScanChat::Thread.create(DATA[:threads][1]).save

      get 'api/v1/threads'
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single thread' do
      @thread_data = DATA[:threads][0]
      ScanChat::Thread.create(@thread_data).save
      id = ScanChat::Thread.first.id

      get "/api/v1/threads/#{id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data']['attributes']['id']).must_equal id
      _(result['data']['attributes']['name']).must_equal @thread_data['name']
    end

    it 'SAD: should return error if unknown thread requested' do
      get '/api/v1/threads/foobar'

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      ScanChat::Thread.create(name: 'New Thread', thread_type: 'chatroom')
      ScanChat::Thread.create(name: 'Newer Thread', thread_type: 'chatroom')
      get 'api/v1/thread/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Threads' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @thread_data = DATA[:threads][0]
    end

    it 'HAPPY: should be able to create a new thread' do
      post 'api/v1/threads', @thread_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      thread = ScanChat::Thread.first

      _(created['id']).must_equal thread.id
      _(created['name']).must_equal @thread_data['name']
      # _(created['members']).must_equal @thread_data['members']
    end

    it 'SECURITY: should not create thread with mass assignment' do
      bad_data = @thread_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/threads', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
