# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# Web API
gem 'json'
gem 'puma', '~>6.2'
gem 'roda', '~>3.54'

# Configuration
gem 'figaro', '~>1.2'
gem 'rake', '~>13.0'

# Security
gem 'bundler-audit'
gem 'rbnacl', '~>7.1'

# Database
gem 'hirb', '~>0.7'
gem 'sequel', '~>5.67'
group :production do
  gem 'pg'
end

# Encoding
gem 'base64', '~>0.2'

# Testing
group :test do
  gem 'minitest'
  gem 'minitest-rg'
end

# Debugging
gem 'pry' # necessary for rake console

# Development
group :development do
  # debugging
  gem 'rerun'
  
  # Quality
  gem 'rubocop'

  # Performance
  gem 'rubocop-performance'
end

group :development, :test do
  # API testing
  gem 'rack-test'

  # Database
  gem 'sequel-seed'
  gem 'sqlite3', '~>1.6'
end
