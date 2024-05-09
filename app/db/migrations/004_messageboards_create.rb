# frozen_string_literal: true

require 'sequel'
Sequel.migration do
  change do
    create_table(:messageboards) do
      uuid :id, primary_key: true
      uuid :thread_id, type: :uuid, foreign_key: { table: :threads, key: :id, type: :uuid }

      Boolean :is_anonymous, null: false

      DateTime :created_at
      DateTime :updated_at
      unique :thread_id
    end
  end
end
