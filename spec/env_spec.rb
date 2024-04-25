# frozen_string_literal: true

# Database Setup
describe 'Secret credentials not exposed' do
  it 'should not find database url' do
    _(Chats::Api.config.DATABASE_URL).must_be_nil
  end
end
