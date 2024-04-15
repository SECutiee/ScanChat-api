require 'json'
require 'base64'
require 'rbnacl'

module Chats
  STORE_DIR = 'app/db/store'

  class CHATROOM
    # Create a new chatroom by passing in a hash of initialization attributes
    def initialize(new_chatroom)
      @id = new_chatroom[:id] || new_id
      @name = new_chatroom[:name]
      @members = new_chatroom[:members]
      @messages = new_chatroom[:messages]
      @message_count = @messages.length
    end

    # def initialize(name)
    #   @id = new_id
    #   @name = name
    #   @members = []
    #   @messages = []
    #   @message_count = 0
    # end

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

    # Stores chatroom in file store
    require 'json'

    def save
      FileUtils.mkdir_p(Chats::STORE_DIR) unless Dir.exist?(Chats::STORE_DIR)
      File.write("#{Chats::STORE_DIR}/#{id}.txt", JSON.generate(to_h))
    end

    def self.find(id)
      chatroom_file = File.read("#{Chats::STORE_DIR}/#{id}.txt")
      CHATROOM.new JSON.parse(chatroom_file)
    end

    # Query method to retrieve index of all chatrooms
    def self.all
      Dir.glob("#{Chats::STORE_DIR}/*.txt").map do |file|
        file.match(%r{#{Regexp.quote(Chats::STORE_DIR)}/(.*)\.txt})[1]
      end
    end

    attr_reader :id, :name, :members

    def add_message(content, sender_id)
      # generate id for new message
      id = @message_count + 1
      @messages.push(Chats::MESSAGE.new(id, content, sender_id, Time.now))
      @message_count += 1
    end

    private

    def new_id
      timestamp = Time.now.to_f.to_s
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end
  end

  class MESSAGE
    def initialize(new_message)
      @id = new_message[:id]
      @content = new_message[:content]
      @sender_id = new_message[:sender_id]
      @timestamp = new_message[:timestamp]
    end
  end
end
new_messages = [Chats::MESSAGE.new({ id: 1, content: 'Hello', sender_id: 'user1', timestamp: Time.now }),
                Chats::MESSAGE.new({ id: 2, content: 'Hi', sender_id: 'user2', timestamp: Time.now })]
# Create a new chatroom
new_chatroom = Chats::CHATROOM.new({ name: 'chatroom1', members: %w[user1 user2], messages: new_messages })
new_chatroom.save

# Retrieve the chatroom
retrieved_chatroom = Chats::CHATROOM.find('chatroom1')
puts retrieved_chatroom.to_json
