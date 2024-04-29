# frozen_string_literal: true

require 'sequel'
Sequel.migration do
  change do
    create_table(:chatrooms) do
      uuid :id, primary_key: true

      String :name_secure, null: false
      String :members, null: false, default: ''
      String :description_secure, null: false, default: ''

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
