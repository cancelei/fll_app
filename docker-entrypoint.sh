#!/bin/bash
set -e

# Run migrations on startup
echo "Running database migrations..."
bin/rails db:migrate

# Start SolidQueue in the background
echo "Starting SolidQueue worker..."
bin/rails solid_queue:start &

# Start the Rails web server
echo "Starting Rails server..."
exec bundle exec puma -C config/puma.rb
