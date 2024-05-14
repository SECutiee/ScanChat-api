# Chat API

## Overview
The Chat API, developed in Ruby and utilizing the Roda framework, enables the creation and management of chatrooms with real-time communication capabilities. It facilitates chatroom operations through HTTP requests, with JSON data exchange, and includes a simple file-based persistent data storage.

## Features
- **Chatroom Creation**: Users can initiate new chatrooms.
- **Retrieving Chatroom Details**: Users can request the information of a chatroom
- **Listing All Chatrooms**: Users can get a list of all available chatrooms
- **Persistent Storage**: Chatrooms and messages are stored in a file system for durability.

## Prerequisites
- Ruby environment
- Bundler for Ruby dependency management

## Installation

### Clone the Repository:
```sh
git clone https://github.com/yourusername/chats-api.git
cd chats-api
```

### Install Dependencies:
```sh
bundle install
```

### Start the Server:
```sh
rake run:dev
```

## Usage

### Creating a Chatroom
To create a chatroom, send a POST request with the chatroom's name and initial members:
```bash
http POST /api/v1/chatrooms name="Chatroom Example" members:='["user1","user2"]'
```

**Positive Response**:
```json
{
  "message": "Chatroom created"
  "id" : "<the assigned id of the chatroom>"
}
```

### Retrieving Chatroom Details
Retrieve the details of a specific chatroom by its ID:
```bash
http GET /api/v1/chatrooms/chatroom_id
```

### Listing All Chatrooms
List the IDs of all chatrooms:
```bash
http GET /api/v1/chatrooms
```

**Response Example**:
```json
{
  "chatroom_ids": ["generated_chatroom_id1", "generated_chatroom_id2"]
}
```

## Data Formats
**Chatroom**:
```json
{
  "id": "generated_chatroom_id",
  "name": "Chatroom Example",
  "members": [
    "user1",
    "user2"
  ],
  "message_count": 2,
  "messages": [
    {
      "id": 1,
      "content": "Hello, World!",
      "sender_id": "user1",
      "timestamp": "2024-04-16T12:34:56+00:00"
    },
    {
      "id": 2,
      "content": "Hi there!",
      "sender_id": "user2",
      "timestamp": "2024-04-16T12:35:01+00:00"
    }
  ]
}
```

**Message:**

```json
{
  "id": 1,
  "content": "Hello, World!",
  "sender_id": "user1",
  "timestamp": "2024-04-16T12:34:56+00:00"
}
```

## License
This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
