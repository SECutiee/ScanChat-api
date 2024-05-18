# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test chatrooms Handling' do ###
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Getting chatrooms' do ###
    it 'HAPPY: should be able to get list of all chatrooms' do
      create_accounts(DATA[:accounts])
      create_owned_chatrooms(DATA[:accounts], DATA[:chatrooms])

      get 'api/v1/chatrooms' ### ask should it be sth like => api/v1/threads/chatrooms ??
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 2
    end

    it 'HAPPY: should be able to get all chatrooms that an account owns' do
      create_accounts(DATA[:accounts])
      create_owned_chatrooms(DATA[:accounts], DATA[:chatrooms])
      chatroom = ScanChat::Chatroom.first
      owner = chatroom.owner

      get "api/v1/accounts/#{owner.username}/chatrooms"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 1
      _(result['data'][0]['attributes']['thread']['attributes']['owner_id']).must_equal owner.id
    end

    it 'HAPPY: should be able to get a list of all chatrooms that an account joined' do
      create_accounts(DATA[:accounts])
      create_owned_chatrooms(DATA[:accounts], DATA[:chatrooms])
      add_members_to_chatrooms(DATA[:members])
      account = ScanChat::Account.first

      get "api/v1/accounts/#{account.username}/joined_chatrooms" # TODO: maybe change route
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal account.joined_chatrooms.count
    end

    it 'HAPPY: should be able to get details of a single chatroom' do
      create_accounts(DATA[:accounts])
      create_owned_chatrooms(DATA[:accounts], DATA[:chatrooms])

      thread = ScanChat::Thread.order(Sequel.desc(:created_at)).first
      thread_id = thread.id

      get "/api/v1/chatrooms/#{thread_id}" ### ask same Q in line 17
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['attributes']['thread_id']).must_equal thread_id
      _(result['attributes']['thread']['attributes']['name']).must_equal thread.name
    end

    it 'SAD: should return error if unknown chatroom requested' do ###
      get '/api/v1/chatrooms/foobar' ### ask

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      create_accounts(DATA[:accounts])
      create_owned_chatrooms(DATA[:accounts], DATA[:chatrooms])
      get 'api/v1/chatrooms/2%20or%20id%3E0' ### TODO this doesn't make sense

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Chatrooms' do ###
    before do
      wipe_database
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @chatr_data = DATA[:chatrooms][0].dup ### ask
      @chatr_owner_username = @chatr_data.delete('owner_username')
      create_accounts(DATA[:accounts])
    end

    it 'HAPPY: should be able to create a new chatroom for existing user' do
      # puts "Request data: #{@chatr_data.to_json}"
      post "api/v1/accounts/#{@chatr_owner_username}/chatrooms", @chatr_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      chatr = ScanChat::Chatroom.order(Sequel.desc(:created_at)).first

      _(created['id']).must_equal chatr.id ###
      _(created['thread_id']).must_equal chatr.thread.id
      _(created['thread']['attributes']['name']).must_equal @chatr_data['name']
      _(created['thread']['attributes']['description']).must_equal @chatr_data['description']
    end

    it 'SECURITY: should not create chatroom with mass assignment' do ###
      bad_data = @chatr_data.clone ###
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/accounts/#{@chatr_owner_username}/chatrooms", bad_data.to_json, @req_header ###

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
