# frozen_string_literal: true

require 'sequel'
Sequel.migration do
  change do
    create_table(:threads) do
      uuid :id, primary_key: true
      String :threadable_type, null: false
      String :threadable_id, default: ''

      String :name_secure, null: false
      String :description_secure, null: false, default: ''
      String :owner_id, null: false
      DateTime :expiration_date

      DateTime :created_at
      DateTime :updated_at
    end

    alter_table(:threads) do
      add_constraint(:check_threadable_type, Sequel.|(
                                               { threadable_type: 'chatroom' },
                                               { threadable_type: 'messageboard' }
                                             ))
    end
  end
end
