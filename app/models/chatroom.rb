require 'json'
require 'base64'
require 'rbnacl'
require 'time'

module Chats
  # represents a chatroom in the system
  class Chatroom < Sequel::Model
    one_to_many :messages
    plugin :association_dependencies, messages: :destroy

    plugin :timestamps

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

    # def self.add_message(chatroom_id, sender_id, content)
    #   chatroom = find(chatroom_id)
    #   chatroom.add_message(sender_id, content)
    #   chatroom.save
    # end

    # def add_message(sender_id, content)
    #   # generate id for new message
    #   id = @message_count
    #   @messages.push(Chats::Message.new({ id:, content:, sender_id:, timestamp: Time.now }))
    #   @message_count += 1
    # end
  end
end
