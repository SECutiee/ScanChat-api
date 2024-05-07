# frozen_string_literal: true

require 'sequel'
Sequel.migration do
  change do
    create_table(:chatrooms) do
      uuid :id, primary_key: true
      foreign_key :thread_id, table: :threads

      String :members, null: false, default: ''
      Boolean :is_private, default: false, null: false
      DateTime :link_expiration

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
