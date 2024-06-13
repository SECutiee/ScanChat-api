# frozen_string_literal: true

require './app/controllers/helpers'
include ScanChat::SecureRequestHelpers # rubocop:disable Style/MixinUsage

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, chatrooms, messageboards, messages'
    create_accounts
    create_owned_chatrooms
    create_owned_messageboards
    add_messages_to_chatroom
    add_messages_to_messageboard
    add_members_to_chatrooms
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
OWNER_INFO = YAML.load_file("#{DIR}/owners_threads.yml")
THREAD_INFO = YAML.load_file("#{DIR}/threads_seed.yml")
CHATROOM_INFO = YAML.load_file("#{DIR}/chatrooms_seed.yml")
MESSAGEBOARD_INFO = YAML.load_file("#{DIR}/messageboards_seed.yml")
MESSAGES_INFO = YAML.load_file("#{DIR}/messages_seed.yml")
MEMBER_INFO = YAML.load_file("#{DIR}/chatrooms_members.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    ScanChat::Account.create(account_info)
  end
end

def create_owned_chatrooms # rubocop:disable Metrics/MethodLength
  ACCOUNTS_INFO.each do |owner|
    account = ScanChat::Account.first(username: owner['username'])
    chatr_data = CHATROOM_INFO.select { |chatr| chatr['owner_username'] == owner['username'] }

    chatr_data.each do |chatr|
      new_chatroom = ScanChat::CreateChatroomForOwner.call(
        owner_id: account.id, name: chatr['name'], is_private: chatr['is_private']
      )
      new_chatroom.description = chatr['description']
      new_chatroom.save
    end
  end
end

def create_owned_messageboards # rubocop:disable Metrics/MethodLength
  ACCOUNTS_INFO.each do |owner|
    account = ScanChat::Account.first(username: owner['username'])
    msgb_data = MESSAGEBOARD_INFO.select { |msgb| msgb['owner_username'] == owner['username'] }

    msgb_data.each do |msgb|
      new_messageboard = ScanChat::CreateMessageboardForOwner.call(
        owner_id: account.id, name: msgb['name'], is_anonymous: msgb['is_anonymous']
      )
      new_messageboard.description = msgb['description']
      new_messageboard.save
    end
  end
end

def add_messages_to_chatroom
  MESSAGES_INFO.each do |message|
    thread = ScanChat::Thread.all.find { |thr| thr.name == message['thread_name'] }
    sender = ScanChat::Account.first(username: message['sender_username'])
    next unless thread.chatroom

    ScanChat::AddMessageToChatroom.call(account: sender, chatroom: thread.chatroom, message_data: message)
  end
end

def add_messages_to_messageboard
  MESSAGES_INFO.each do |message|
    thread = ScanChat::Thread.all.find { |thr| thr.name == message['thread_name'] }
    # _sender = ScanChat::Account.first(username: message['sender_username'])
    next unless thread.messageboard

    ScanChat::AddMessageToMessageboard.call(messageboard: thread.messageboard, message_data: message)
  end
end

def add_members_to_chatrooms
  MEMBER_INFO.each do |member_chatroom|
    member_chatroom['username'].each do |username|
      chatr_id = ScanChat::Chatroom.all.find { |chatr| chatr.name == member_chatroom['chatroom_name'] }.id
      ScanChat::AddMemberToChatroom.call(username: username, chatroom_id: chatr_id)
    end
  end
end
