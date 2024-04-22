# frozen_string_literal: true

require 'sequel'
Sequel.migration do
  change do
    create_table(:messages) do
      primary_key :id
      foreign_key :chatroom_id, table: :chatrooms
      String :content, null: false
      String :sender_id, null: false
      String :timestamp, null: false
      DateTime :created_at
      DateTime :updated_at
      unique [:chatroom_id, :id]
    end
  end
end
