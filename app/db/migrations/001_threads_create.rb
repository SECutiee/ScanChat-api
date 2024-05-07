# frozen_string_literal: true

require 'sequel'
Sequel.migration do
  change do
    create_table(:threads) do
      uuid :id, primary_key: true

      String :name_secure, null: false
      String :description_secure, null: false, default: ''
      String :owner
      DateTime :expiration_date

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
