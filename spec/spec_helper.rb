# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:messages].delete
  app.DB[:chatrooms].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:chatrooms] = YAML.safe_load_file('app/db/seeds/chatroom_seeds.yml')
DATA[:messages] = YAML.safe_load_file('app/db/seeds/message_seeds.yml')
