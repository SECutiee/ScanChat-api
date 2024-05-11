# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, chatrooms, messageboards, messages'
    create_accounts
    create_owned_threads
    create_chatrooms
    create_messageboards
    create_messages
    add_members_to_chatrooms
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
OWNER_INFO = YAML.load_file("#{DIR}/owners_threads.yml")
THREAD_INFO = YAML.load_file("#{DIR}/threads_seed.yml")
CHATROOM_INFO = YAML.load_file("#{DIR}/threads_chatrooms.yml")
MESSAGEBOARD_INFO = YAML.load_file("#{DIR}/threads_messageboards.yml")
MESSAGES_INFO = YAML.load_file("#{DIR}/messages_seed.yml")
MEMBER_INFO = YAML.load_file("#{DIR}/chatrooms_members.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    ScanChat::Account.create(account_info)
  end
end

def create_owned_threads
  OWNER_INFO.each do |owner|
    account = ScanChat::Account.first(username: owner['username'])
    owner['thread_name'].each do |thread_name|
      thre_data = THREAD_INFO.find { |thread| thread['name'] == thread_name }
      ScanChat::CreateThreadForOwner.call(
        owner_id: account.id, thread_data: thre_data
      )
    end
  end
end

def create_chatrooms
  THREAD_INFO.each do |thread|
    thre = ScanChat::Thread.first(name_secure: thread['name'])
    chatr_data = CHATROOM_INFO.find do |chatroom|
      thread['name'] == chatroom['thread_name'] && thread['type'] == 'chatroom'
    end
    ScanChat::CreateChatroomForThread.call(
      thread_id: thre.id, chatroom_data: chatr_data
    )
  end
end

def create_messageboards
  THREAD_INFO.each do |thread|
    thre = ScanChat::Thread.first(name_secure: thread['name'])
    messageb_data = MESSAGEBOARD_INFO.find do |messageboard|
      thread['name'] == messageboard['thread_name'] && thread['type'] == 'messageboard'
    end
    ScanChat::CreateMessageboardForThread.call(
      thread_id: thre.id, messageboard_data: messageb_data
    )
  end
end

def create_messages
  mes_info_each = MESSAGES_INFO.each
  threads_cycle = ScanChat::Thread.all.cycle
  loop do
    mes_info = mes_info_each.next
    thread = threads_cycle.next
    ScanChat::CreateMessageForThread.call(
      thread_id: thread.id, message_data: mes_info
    )
  end
end

def add_members_to_chatrooms
  member_info = MEMBER_INFO
  member_info.each do |thread|
    thre = ScanChat::Thread.first(name: thread['thread_name'])
    thread['username'].each do |member|
      account = ScanChat::Account.first(username: member)
      ScanChat::AddMemberToChatroom.call(
        account: account.id, thread_id: thre.id
      )
    end
  end
end