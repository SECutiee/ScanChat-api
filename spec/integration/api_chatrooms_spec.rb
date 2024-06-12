# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test chatrooms Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = ScanChat::Account.create(@account_data)
    @wrong_account = ScanChat::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting chatrooms' do
    describe 'Getting list of chatrooms' do
      before do
        @account.create_owned_chatrooms(DATA[:chatrooms][0])
        @account.create_owned_chatrooms(DATA[:chatrooms][1])

        # @account_data = DATA[:accounts][0]
        # create_owned_chatrooms(DATA[:accounts], DATA[:chatrooms])
      end

      it 'HAPPY: should get list for authorized account' do
        header 'AUTHORIZATION', auth_header(@account_data)

        header 'AUTHORIZATION', "Bearer #{auth[:attributes][:auth_token]}"
        get 'api/v1/chatrooms'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'BAD: should not process without authorization' do
        get 'api/v1/chatrooms'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end

    it 'HAPPY: should be able to get list of all chatrooms' do
      create_accounts(DATA[:accounts])
      create_owned_chatrooms(DATA[:accounts], DATA[:chatrooms])

      get 'api/v1/chatrooms'
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

      get "api/v1/accounts/#{account.username}/joined_chatrooms"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal account.joined_chatrooms.count
    end

    it 'HAPPY: should be able to get details of a single chatroom' do
      thread = @account.add_owned_chatroom(DATA[:chatrooms][0])

      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/chatrooms/#{thread.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['thread_id']).must_equal thread.id
      _(result['attributes']['thread']['name']).must_equal thread.name

      create_accounts(DATA[:accounts])
      create_owned_chatrooms(DATA[:accounts], DATA[:chatrooms])
    end

    it 'SAD: should return error if unknown chatroom requested' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/chatrooms/foobar'

      _(last_response.status).must_equal 404
    end

    it 'BAD AUTHORIZATION: should not get chatroom with wrong authorization' do
      chatr = @account.add_owned_chatroom(DATA[:chatrooms][0])

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/chatrooms/#{chatr.thread_id}"
      _(last_response.status).must_equal 403

      result = JSON.parse last_response.body
      _(result['attributes']).must_be_nil
    end

    it 'BAD SQL VULNERABILTY: should prevent basic SQL injection of id' do
      create_accounts(DATA[:accounts])
      create_owned_chatrooms(DATA[:accounts], DATA[:chatrooms])

      header 'AUTHORIZATION', auth_header(@account_data)
      get 'api/v1/chatrooms/2%20or%20id%3E0' ### TODO this doesn't make sense

      # deliberately not reporting detection -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Chatrooms' do
    before do
      wipe_database
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @chatr_data = DATA[:chatrooms][0].dup
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

      _(created['id']).must_equal chatr.id
      _(created['thread_id']).must_equal chatr.thread.id
      _(created['thread']['attributes']['name']).must_equal @chatr_data['name']
      _(created['thread']['attributes']['description']).must_equal @chatr_data['description']
    end

    it 'SECURITY: should not create chatroom with mass assignment' do
      bad_data = @chatr_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/accounts/#{@chatr_owner_username}/chatrooms", bad_data.to_json, @req_header ###

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end

# describe 'Joining Chatroom' do
# end

# describe 'Leaving Chatroom' do
# end

# describe 'Deleting Chatroom' do
# end
