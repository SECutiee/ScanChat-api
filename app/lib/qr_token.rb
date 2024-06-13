# frozen_string_literal: true

require 'base64'
require_relative 'securable'

## Token and Detokenize Authorization Information
# Usage examples:
#  AuthToken.setup(AuthToken.generate_key)
#  token = AuthToken.create({ key: 'value', key2: 12 }, AuthToken::ONE_MONTH)
#  AuthToken.new(token).payload   # => {"key"=>"value", "key2"=>12}
class QRToken
  extend Securable

  ONE_HOUR = 60 * 60
  ONE_DAY = ONE_HOUR * 24
  ONE_WEEK = ONE_DAY * 7
  ONE_MONTH = ONE_WEEK * 4
  ONE_YEAR = ONE_MONTH * 12
  ACTIONS = [:join].freeze

  class ExpiredTokenError < StandardError; end
  class InvalidTokenError < StandardError; end

  # Extract information from a token
  def initialize(token)
    @token = token
    contents = AuthToken.detokenize(@token)
    @expiration = contents['exp']
    @action = contents['action']
    @thread_id = contents['thread_id']
    @token_creator_id = contents['token_creator_id']
    raise InvalidTokenError unless ACTIONS.include?(@action)
    raise InvalidTokenError if @action.is_nil? || @thread_id.is_nil? || @token_creator_id.is_nil?
  end

  # Check if token is expired
  def expired?
    Time.now > Time.at(@expiration)
  rescue StandardError
    raise InvalidTokenError
  end

  # Check if token is not expired
  def fresh? = !expired?

  # Extract data from token
  def action
    expired? ? raise(ExpiredTokenError) : @action
  end

  def thread_id
    expired? ? raise(ExpiredTokenError) : @thread_id
  end

  def token_creator_id
    expired? ? raise(ExpiredTokenError) : @token_creator_id
  end

  def to_s = @token

  # Create a token from a Hash payload
  def self.create(action, thread_id, token_creator_id, expiration = ONE_DAY)
    contents = { 'action' => action,
                 'thread_id' => thread_id,
                 'token_creator_id' => token_creator_id,
                 'exp' => expires(expiration) }
    AuthToken.new(tokenize(contents))
  end

  def self.expires(expiration)
    (Time.now + expiration).to_i
  end

  # Tokenize contents or return nil if no data
  def self.tokenize(message)
    return nil unless message

    message_json = message.to_json
    ciphertext = base_encrypt(message_json)
    Base64.urlsafe_encode64(ciphertext)
  end

  # Detokenize and return contents, or raise error
  def self.detokenize(ciphertext64)
    return nil unless ciphertext64

    ciphertext = Base64.urlsafe_decode64(ciphertext64)
    message_json = base_decrypt(ciphertext)
    JSON.parse(message_json)
  rescue StandardError
    raise InvalidTokenError
  end
end
