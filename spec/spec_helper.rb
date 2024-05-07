# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:messages].delete
  app.DB[:threads].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:threads] = YAML.safe_load_file('app/db/seeds/thread_seeds.yml')
DATA[:messages] = YAML.safe_load_file('app/db/seeds/message_seeds.yml')
