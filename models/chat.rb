require 'json'
require 'base64'
require 'rbnacl'
require 'time'

module Chats
  STORE_DIR = 'app/db/store'

  class CHATROOM
    # Create a new chatroom by passing in a hash of initialization attributes
    def initialize(new_chatroom)
      @id = new_chatroom['id'] || new_chatroom[:id] || new_id
      @name = new_chatroom['name'] || new_chatroom[:name]
      @members = new_chatroom['members'] || new_chatroom[:members]
      @messages = new_chatroom['messages'] || new_chatroom[:messages]
      unless @messages.empty? || @messages[0].instance_of?(Chats::MESSAGE)
        @messages.map! do |message|
          Chats::MESSAGE.new(message)
        end
      end
      @message_count = new_chatroom['message_count'] || new_chatroom[:message_count] || @messages.length
    end

    attr_reader :id, :name, :members, :message_count, :messages

    def to_json(_options = {})
      JSON(
        {
          id: @id,
          name: @name,
          members: @members,
          message_count: @message_count,
          messages: @messages
        }
      )
    end

    def add_message(content, sender_id)
      # generate id for new message
      id = @message_count + 1
      @messages.push(Chats::MESSAGE.new(id, content, sender_id, Time.now))
      @message_count += 1
    end

    def save
      FileUtils.mkdir_p(Chats::STORE_DIR) unless Dir.exist?(Chats::STORE_DIR)
      File.write("#{Chats::STORE_DIR}/#{id}.txt", to_json)
    end

    # File store must be setup once when application runs
    def self.setup
      Dir.mkdir(Credence::STORE_DIR) unless Dir.exist? Credence::STORE_DIR
    end

    def self.find(id)
      chatroom_file = File.read("#{Chats::STORE_DIR}/#{id}.txt")
      CHATROOM.new(JSON.parse(chatroom_file))
    end

    # Query method to retrieve index of all chatrooms
    def self.all
      Dir.glob("#{Chats::STORE_DIR}/*.txt").map do |file|
        file.match(%r{#{Regexp.quote(Chats::STORE_DIR)}/(.*)\.txt})[1]
      end
    end

    private

    def new_id
      timestamp = Time.now.to_f.to_s
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end
  end

  class MESSAGE
    def initialize(new_message)
      @id = new_message['id'] || new_message[:id]
      @content = new_message['content'] || new_message[:content]
      @sender_id = new_message['sender_id'] || new_message[:sender_id]
      @timestamp = new_message['timestamp'] || new_message[:timestamp]
    end

    def to_json(_options = {})
      JSON(
        {
          id: @id,
          content: @content,
          sender_id: @sender_id,
          timestamp: @timestamp
        }
      )
    end
  end
end
