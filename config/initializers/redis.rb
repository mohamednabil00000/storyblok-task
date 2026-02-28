# frozen_string_literal: true

require "redis"

# Use an environment variable to set the URL, fallback to default
$redis = Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"))

# Alternatively, configure with specific host/port/db
# $redis = Redis.new(host: "localhost", port: 6379, db: 0)
