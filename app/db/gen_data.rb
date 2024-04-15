new_messages = [Chats::MESSAGE.new({ "id": 1, "content": 'Hello', "sender_id": 'user1', "timestamp": Time.now }),
                Chats::MESSAGE.new({ "id": 2, "content": 'Hi', "sender_id": 'user2', "timestamp": Time.now })]
# Create a new chatroom
new_chatroom = Chats::CHATROOM.new({ "name": 'chatroom1', "members": %w[user1 user2],
                                     "messages": new_messages })
# new_chatroom.save

# Retrieve the chatroom
retrieved_chatroom = Chats::CHATROOM.find(new_chatroom.id)
puts retrieved_chatroom.to_json

parsed_messages = [
  { content: 'Haha', sender_id: 'Tristan', timestamp: '2024-03-22T22:05:00' },
  { content: 'Ohhh I see I mean you can try taking the campus bus from the canteens', sender_id: '丁怡萱 Fifi',
    timestamp: '2024-03-22T22:27:00' },
  { content: 'There’s like this secret stairs from our school’s hung dorm, but idk if you’ll be able to find it',
    sender_id: '丁怡萱 Fifi', timestamp: '2024-03-22T22:28:00' },
  { content: "I went there once, I'll figure it out 🤔", sender_id: 'Tristan', timestamp: '2024-03-30T14:38:00' },
  { content: 'Are you free at 17:30 ?~', sender_id: '映汝 Ju', timestamp: '2024-04-08T14:05:00' },
  { content: 'Sorry I’m not', sender_id: '丁怡萱 Fifi', timestamp: '2024-04-08T15:37:00' },
  { content: "Where exactly are we gonna meet? I'm at the tsmc building studying currently", sender_id: 'Tristan',
    timestamp: '2024-04-08T17:24:00' },
  { content: 'I am on 3F now~ maybe we can meet at discussion room on 3F~ wait for @鍾宜娟', sender_id: '映汝 Ju',
    timestamp: '2024-04-08T17:33:00' },
  { content: 'Okay! The class just ended🥹 give me 10 min!', sender_id: '鍾宜娟', timestamp: '2024-04-08T17:40:00' },
  { content: 'unsent a message.', sender_id: '映汝 Ju', timestamp: '2024-04-09T12:47:00' },
  { content: "heyy, I'm at Louisa now just let me know when you arrive at the library", sender_id: 'Tristan',
    timestamp: '2024-04-11T13:53:00' },
  { content: "I'll be a bit late! Just get on the bus 🚐🚐(emoji)", sender_id: '鍾宜娟', timestamp: '2024-04-11T14:00:00' },
  { content: "I'm arrive at 6f", sender_id: '映汝 Ju', timestamp: '2024-04-11T14:00:00' },
  { content: 'around 603', sender_id: '映汝 Ju', timestamp: '2024-04-11T14:01:00' },
  { content: 'coming..', sender_id: 'Tristan', timestamp: '2024-04-11T14:08:00' },
  { content: "no rush Angel haven't arrive yet", sender_id: '映汝 Ju', timestamp: '2024-04-11T14:09:00' },
  { content: 'Angel is coming haha', sender_id: '映汝 Ju', timestamp: '2024-04-11T14:10:00' },
  { content: 'Photos', sender_id: '映汝 Ju', timestamp: '2024-04-11T14:26:00' },
  { content: 'Could we arrange meeting on Tuesday at 17:30-around 19. ?', sender_id: '映汝 Ju',
    timestamp: '2024-04-15T02:39:00' },
  { content: 'or Tuesday morning...?', sender_id: '映汝 Ju', timestamp: '2024-04-15T02:41:00' },
  {
    content: "Hey, the morning doesn't work for me since I have class. But 5:30 is fine for me. (Also why are you awake so late 🥶?)", sender_id: 'Tristan', timestamp: '2024-04-15T08:47:00'
  }
]
# Convert parsed messages to Chats::MESSAGE instances
messages = parsed_messages.map do |msg|
  Chats::MESSAGE.new({
                       'content' => msg[:content],
                       'sender_id' => msg[:sender_id],
                       'timestamp' => Time.parse(msg[:timestamp])
                     })
end

# Create a new chatroom with these messages
chatroom = Chats::CHATROOM.new({
                                 'name' => 'Group Project Discussion',
                                 'members' => parsed_messages.map { |msg| msg[:sender_id] }.uniq,
                                 'messages' => messages
                               })

# Save the chatroom to the file system
chatroom.save
