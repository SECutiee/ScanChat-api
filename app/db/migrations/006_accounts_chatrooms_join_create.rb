# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(member_id: { table: :accounts, type: :uuid }, chatroom_id: { table: :chatrooms, type: :uuid })
  end
end
