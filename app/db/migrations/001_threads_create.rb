# frozen_string_literal: true

require 'sequel'
Sequel.migration do
  change do
    create_table(:threads) do
      uuid :id, primary_key: true
      add_foreign_key :owner_id, table: :accounts

      String :thread_type, null: false
      String :name_secure, null: false
      String :description_secure, null: false, default: ''
      DateTime :expiration_date

      DateTime :created_at
      DateTime :updated_at
    end

    alter_table(:threads) do
      add_constraint(:check_thread_type, Sequel.|(
                                           { thread_type: 'chatroom' },
                                           { thread_type: 'messageboard' }
                                         ))
    end
  end
end
