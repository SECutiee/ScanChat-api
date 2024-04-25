# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Test Chatroom Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'HAPPY: should be able to get a list of all chatrooms' do
    Chats::Chatroom.create(DATA[:chatrooms][0]).save
    Chats::Chatroom.create(DATA[:chatrooms][1]).save

    get 'api/v1/chatrooms'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single chatroom' do
    existing_chatr = DATA[:chatrooms][0]
    Chats::Chatroom.create(existing_chatr).save
    id = Chats::Chatroom.first.id

    get "/api/v1/chatrooms/#{id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal id
    _(result['data']['attributes']['name']).must_equal existing_chatr['name']
  end

  it 'SAD: should return error if unknown chatroom requested' do
    get '/api/v1/chatrooms/foobar'

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create a new chatroom' do
    existing_chatr = DATA[:chatrooms][0]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/chatrooms', existing_chatr.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.headers['Location']).must_match(%r{api/v1/chatrooms/\d+})

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    chatr = Chats::Chatroom.first

    _(created['id']).must_equal chatr.id
    _(created['name']).must_equal existing_chatr['name']
    _(created['members']).must_equal existing_chatr['members']
  end
end
