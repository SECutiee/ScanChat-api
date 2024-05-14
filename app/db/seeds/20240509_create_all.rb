# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, chatrooms, messageboards, messages'
    create_accounts
    create_owned_chatrooms
    create_owned_messageboards
    add_messages
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

def create_owned_chatrooms
  ACCOUNTS_INFO.each do |owner|
    account = ScanChat::Account.first(username: owner['username'])
    # CHATROOM_INFO.each do |chatroom|

    chatr_data = CHATROOM_INFO.select { |chatr| chatr['owner_username'] == owner['username'] }

    chatr_data.each{|chatroom|
      new_chatroom = ScanChat::CreateChatroomForOwner.call(
        owner_id: account.id, name: chatroom['name'], is_private: chatroom['is_private']
      )
      new_chatroom.description = chatroom['description']
      new_chatroom.save
    }

    end
  # end
end

def create_owned_messageboards
  ACCOUNTS_INFO.each do |owner|
    account = ScanChat::Account.first(username: owner['username'])
    # CHATROOM_INFO.each do |messageboard|

    msgb_data = MESSAGEBOARD_INFO.select { |msgb| msgb['owner_username'] == owner['username'] }

    msgb_data.each{ |msgb|
      new_messageboard = ScanChat::CreateMessageboardForOwner.call(
        owner_id: account.id, name: msgb['name'], is_anonymous: msgb['is_anonymous']
      )
      new_messageboard.description = msgb['description']
      new_messageboard.save
    }

    end
  # end
end
# msgb_data = MESSAGEBOARD_INFO.select { |msgb| msgb['owner_username'] == owner['username'] }
def add_messages
  MESSAGES_INFO.each do |message|
    thread = ScanChat::Thread.all.find{|thread|  thread.name == message['thread_name']}
    sender = ScanChat::Account.first(username: message['sender_username'])
    ScanChat::AddMessageToThread.call(thread_id: thread.id, content: message['content'], sender_id: sender.id)
  end
end

def add_members_to_chatrooms
  MEMBER_INFO.each do |member_chatroom|
    member_chatroom['username'].each do |username|
      chatr_id = ScanChat::Chatroom.all.find{|chatroom| chatroom.name == member_chatroom['chatroom_name']}.id
      ScanChat::AddMemberToChatroom.call(username: username, chatroom_id: chatr_id)
    end
  end
end
