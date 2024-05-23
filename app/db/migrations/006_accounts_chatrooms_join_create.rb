# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(member_id: :accounts, chatroom_id: :chatrooms) do
      column :member_id, 'uuid', null: false
      column :chatroom_id, 'uuid', null: false
    end
  end
end
