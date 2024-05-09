# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test messageboards Handling' do ###
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Getting messageboards' do ###
    it 'HAPPY: should be able to get list of all messageboards' do ###
      ScanChat::Thread.create(DATA[:threads][0]) ### ask
      ScanChat::Thread.create(DATA[:threads][1]) ### ask

      get 'api/v1/messageboards' ### ask should it be sth like => api/v1/threads/messageboards ??
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single messageboard' do ###
      existing_thre = DATA[:threads][1] ###
      ScanChat::Thread.create(existing_thre) ###
      id = ScanChat::Thread.first.id ###

      get "/api/v1/messageboards/#{id}" ### ask same Q in line 17
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data']['attributes']['id']).must_equal id
      _(result['data']['attributes']['name']).must_equal existing_thre['name'] ### ask
    end

    it 'SAD: should return error if unknown messageboard requested' do ###
      get '/api/v1/messageboards/foobar' ### ask

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      ScanChat::Thread.create(name: 'New messageboard') ###
      ScanChat::Thread.create(name: 'Newer messageboard') ###
      get 'api/v1/threads/2%20or%20id%3E0' ### ask

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Messageboards' do ###
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @thre_data = DATA[:threads][1] ### ask
    end

    it 'HAPPY: should be able to create new messageboards' do ###
      post 'api/v1/messageboards', @thre_data.to_json, @req_header ### ask thre_data
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      thre = ScanChat::Thread.first ###

      _(created['id']).must_equal thre.id ###
      _(created['name']).must_equal @thre_data['name'] ### ask
      _(created['description']).must_equal @thre_data['description'] ### ask description(is in thread db)
    end

    it 'SECURITY: should not create messageboard with mass assignment' do ###
      bad_data = @thre_data.clone ###
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/messageboards', bad_data.to_json, @req_header ###

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
