# frozen_string_literal: true

require 'sequel'
Sequel.migration do
  change do
    create_table(:messageboards) do
      uuid :id, primary_key: true
      foreign_key :thread_id, table: :threads

      Boolean :is_anonymous, default: false, null: false

      DateTime :created_at
      DateTime :updated_at
      unique :thread_id
    end
  end
end
