# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  ScanChat::Account.map(&:destroy)
  ScanChat::Message.map(&:destroy)
  ScanChat::Thread.map(&:destroy)
  ScanChat::Chatroom.map(&:destroy)
  ScanChat::Messageboard.map(&:destroy)
end

def authenticate(account_data)
  ScanChat::AuthenticateAccount.call(
    username: account_data['username'],
    password: account_data['password']
  )
end

def auth_header(account_data)
  auth = authenticate(account_data)
  "Bearer #{auth[:attributes][:auth_token]}"
end

def authorization(account_data)
  auth = authenticate(account_data)

  token = AuthToken.new(auth[:attributes][:auth_token])
  account = token.payload['attributes']
  { account: ScanChat::Account.first(username: account['username']),
    scope: AuthScope.new(token.scope) }
end

DATA = {
  accounts: YAML.safe_load_file('app/db/seeds/accounts_seed.yml'),
  threads: YAML.safe_load_file('app/db/seeds/threads_seed.yml'),
  messages: YAML.safe_load_file('app/db/seeds/messages_seed.yml'),
  chatrooms: YAML.safe_load_file('app/db/seeds/chatrooms_seed.yml'),
  messageboards: YAML.safe_load_file('app/db/seeds/messageboards_seed.yml'),
  members: YAML.safe_load_file('app/db/seeds/chatrooms_members.yml')
}.freeze

## SSO fixtures
GH_ACCOUNT_RESPONSE = YAML.load_file('spec/fixtures/github_token_response.yml')
GOOD_GH_ACCESS_TOKEN = GH_ACCOUNT_RESPONSE.keys.first
SSO_ACCOUNT = YAML.load_file('spec/fixtures/sso_account.yml')

def create_accounts(account_data)
  account_data.each do |account_info|
    ScanChat::Account.create(account_info)
  end
end

def create_owned_chatrooms(account_data, chatroom_data)
  account_data.each do |owner|
    account = ScanChat::Account.first(username: owner['username'])
    chatr_data = chatroom_data.select { |chatr| chatr['owner_username'] == owner['username'] }

    chatr_data.each  do |chatroom|
      new_chatroom = ScanChat::CreateChatroomForOwner.call(owner_id: account.id, name: chatroom['name'],
                                                           is_private: chatroom['is_private'])
      new_chatroom.description = chatroom['description']
      new_chatroom.save
    end
  end
end

def create_owned_messageboards(account_data, messageboard_data)
  account_data.each do |owner|
    account = ScanChat::Account.first(username: owner['username'])
    msgb_data = messageboard_data.select { |msgb| msgb['owner_username'] == owner['username'] }

    msgb_data.each do |msgb|
      new_messageboard = ScanChat::CreateMessageboardForOwner.call(owner_id: account.id, name: msgb['name'],
                                                                   is_anonymous: msgb['is_anonymous'])
      new_messageboard.description = msgb['description']
      new_messageboard.save
    end
  end
end

def add_messages(messages_data)
  messages_data.each do |message|
    thread = ScanChat::Thread.all.find { |thr| thr.name == message['thread_name'] }
    sender = ScanChat::Account.first(username: message['sender_username'])
    ScanChat::AddMessageToThread.call(thread_id: thread.id, content: message['content'], sender_id: sender.id)
  end
end

def add_members_to_chatrooms(member_data)
  member_data.each do |member_chatroom|
    member_chatroom['username'].each do |username|
      chatr_id = ScanChat::Chatroom.all.find { |chatroom| chatroom.name == member_chatroom['chatroom_name'] }.id
      ScanChat::AddMemberToChatroom.call(username:, chatroom_id: chatr_id)
    end
  end
end
