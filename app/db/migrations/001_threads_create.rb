# frozen_string_literal: true

require 'sequel'
Sequel.migration do
  change do
    create_table(:threads) do
      uuid :id, primary_key: true
      String :thread_type, null: false

      String :name_secure, null: false
      String :description_secure, null: false, default: ''
      String :owner_id, null: false
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
