# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test messageboards Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = ScanChat::Account.create(@account_data)
    @wrong_account = ScanChat::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting messageboards' do
    it 'HAPPY: should be able to get list of all messageboards' do
      create_accounts(DATA[:accounts])
      create_owned_messageboards(DATA[:accounts], DATA[:messageboards])

      get 'api/v1/messageboards'
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 1
    end

    it 'HAPPY: should be able to get all messageboards that an account owns' do
      create_accounts(DATA[:accounts])
      create_owned_messageboards(DATA[:accounts], DATA[:messageboards])
      messageboard = ScanChat::Messageboard.first
      owner = messageboard.owner

      get "api/v1/accounts/#{owner.username}/messageboards"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 1
      _(result['data'][0]['attributes']['thread']['attributes']['owner_id']).must_equal owner.id
    end

    it 'HAPPY: should be able to get details of a single messageboard' do
      create_accounts(DATA[:accounts])
      create_owned_messageboards(DATA[:accounts], DATA[:messageboards])
      thread = ScanChat::Thread.order(Sequel.desc(:created_at)).first
      thread_id = thread.id

      get "/api/v1/messageboards/#{thread_id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['attributes']['thread_id']).must_equal thread_id
      _(result['attributes']['thread']['attributes']['name']).must_equal thread.name
    end

    it 'SAD: should return error if unknown messageboard requested' do ###
      get '/api/v1/messageboards/foobar'

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      create_accounts(DATA[:accounts])
      create_owned_messageboards(DATA[:accounts], DATA[:messageboards])
      get 'api/v1/messageboards/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Messageboards' do
    before do
      wipe_database
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @msgb_data = DATA[:messageboards][0].dup
      @msgb_owner_username = @msgb_data.delete('owner_username')
      create_accounts(DATA[:accounts])
    end

    it 'HAPPY: should be able to create a new messageboard for existing account' do
      post "api/v1/accounts/#{@msgb_owner_username}/messageboards", @msgb_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      # puts "created data: #{created}"
      msgb = ScanChat::Messageboard.order(Sequel.desc(:created_at)).first ###

      _(created['id']).must_equal msgb.id
      _(created['thread_id']).must_equal msgb.thread.id
      _(created['thread']['attributes']['name']).must_equal @msgb_data['name']
      _(created['thread']['attributes']['description']).must_equal @msgb_data['description']
    end

    it 'SECURITY: should not create messageboard with mass assignment' do
      bad_data = @msgb_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/accounts/#{@msgb_owner_username}/messageboards", bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end

  describe 'Deleting Messageboards' do
    before do
      wipe_database
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @msgb_data = DATA[:messageboards][0].dup
      @msgb_owner_username = @msgb_data.delete('owner_username')
      create_accounts(DATA[:accounts])
      create_owned_messageboards(DATA[:accounts], DATA[:messageboards])
    end

    # it 'HAPPY: should be able to delete a messageboard' do
    #   msgb = ScanChat::Messageboard.order(Sequel.desc(:created_at)).first
    #   msgb_id = msgb.id

    #   delete "/api/v1/messageboards/#{msgb_id}"

    #   _(last_response.status).must_equal 200

    #   result = JSON.parse last_response.body
    #   _(result['data']['id']).must_equal msgb_id
    #   _(ScanChat::Messageboard[msgb_id]).must_be_nil
    # end

    it 'SAD: should return error if unknown messageboard requested for deletion' do
      delete '/api/v1/messageboards/foobar'

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      delete 'api/v1/messageboards/2%20or%20id%3E0'
    end

    #   # deliberately not reporting error -- don't give attacker information
    #   _(last_response.status).must_equal 404
    #   _(last_response.body['data']).must_be_nil
    # end
  end
end
