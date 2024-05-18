#!/bin/bash

# Shell script to reset development and test databases

echo "Dropping development database..."
RACK_ENV=development rake db:drop

echo "Dropping test database..."
RACK_ENV=test rake db:drop

echo "Migrating development database..."
RACK_ENV=development rake db:migrate

echo "Migrating test database..."
RACK_ENV=test rake db:migrate

echo "Database reset complete."
