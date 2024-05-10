# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, chatrooms, messageboards, messages'
    create_accounts
    create_chatrooms
    create_messageboards
    create_messages
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
PROJ_INFO = YAML.load_file("#{DIR}/projects_seed.yml")
