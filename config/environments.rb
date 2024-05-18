# frozen_string_literal: true

require 'roda'
require 'figaro'
require 'logger'
require 'sequel'
require './app/lib/secure_db'

module ScanChat
  # Configuration for the API
  class Api < Roda
    plugin :environments

    # rubocop:disable Lint/ConstantDefinitionInBlock
    configure do
      # load config secrets into local environment variables (ENV)
      Figaro.application = Figaro::Application.new(
        environment: environment, # rubocop:disable Style/HashSyntax
        path: File.expand_path('config/secrets.yml')
      )
      Figaro.load
      def self.config = Figaro.env

      # Database Setup
      db_url = ENV.delete('DATABASE_URL')
      DB = Sequel.connect("#{db_url}?encoding=utf8")
      def self.DB = DB # rubocop:disable Naming/MethodName

      # HTTP Request logging
      configure :development, :production do
        plugin :common_logger, $stdout
      end

      # # Custom events logging
      # LOGGER = Logger.new($stderr)
      # def self.logger = LOGGER

      configure do
        # Set up logging to a file
        log_file_path = File.expand_path('../../log/api.log', __FILE__)
        FileUtils.mkdir_p(File.dirname(log_file_path))
        LOGGER = Logger.new(log_file_path, 'daily')
        def self.logger = LOGGER
      end

      # Load crypto keys
      SecureDB.setup(ENV.delete('DB_KEY'))
    end
    # rubocop:enable Lint/ConstantDefinitionInBlock

    configure :development, :test do
      require 'pry'
      logger.level = Logger::DEBUG
    end
  end
end
