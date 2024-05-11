# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  ScanChat::Message.map(&:destroy)
  ScanChat::Thread.map(&:destroy)
  ScanChat::Account.map(&:destroy)
end

DATA = {
  accounts: YAML.safe_load_file('app/db/seeds/accounts_seed.yml'),
  threads: YAML.safe_load_file('app/db/seeds/threads_seed.yml'),
  messages: YAML.safe_load_file('app/db/seeds/messages_seed.yml'),
  chatrooms: YAML.safe_load_file('app/db/seeds/threads_chatrooms.yml'),
  messageboards: YAML.safe_load_file('app/db/seeds/threads_messageboards.yml')
}.freeze
