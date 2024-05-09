# frozen_string_literal: true

require 'sequel'
Sequel.migration do
  change do
    create_table(:chatrooms) do
      uuid :id, primary_key: true
      uuid :thread_id, type: :uuid, foreign_key: { table: :threads, key: :id, type: :uuid }

      # String :members, null: false, default: ''
      Boolean :is_private, null: false

      DateTime :created_at
      DateTime :updated_at
      unique :thread_id
    end
  end
end
