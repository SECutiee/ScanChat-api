# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(member_id: { table: :accounts, type: :uuid }, chatroom_id: { table: :chatrooms, type: :uuid }) do
      # Define columns explicitly with UUID type
      # column :member_id, 'uuid', null: false
      # column :chatroom_id, 'uuid', null: false

      # # Add foreign key constraints
      # add_foreign_key [:member_id], :accounts, type: 'uuid'
      # add_foreign_key [:chatroom_id], :chatrooms, type: 'uuid'
    end
  end
end
