# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(member_id: :accounts, chatroom_id: :chatrooms) do
      # # Define columns with UUID type
      # column :member_id, 'uuid', null: false
      # column :chatroom_id, 'uuid', null: false

      # # Add foreign key constraints
      # add_foreign_key [:member_id], :accounts, type: 'uuid'
      # add_foreign_key [:chatroom_id], :chatrooms, type: 'uuid'
    end
    set_column_type :accounts_chatrooms, :member_id, :uuid
    set_column_type :accounts_chatrooms, :chatroom_id, :uuid
  end
end
