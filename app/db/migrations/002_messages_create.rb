# frozen_string_literal: true

require 'sequel'
Sequel.migration do
  change do
    create_table(:messages) do
      primary_key :id
      uuid :thread_id, type: :uuid, foreign_key: { table: :threads, key: :id, type: :uuid }
      String :content_secure, null: false
      String :sender_id, null: false

      DateTime :created_at
      DateTime :updated_at
      unique [:thread_id, :id]
    end
  end
end
