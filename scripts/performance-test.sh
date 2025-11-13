#!/bin/bash
# Custom Stage: Performance Test
# Runs after Package stage

set -e

echo "=== Performance Testing ==="

# Start the application in background
echo "Starting application..."
java -jar target/*.jar &
APP_PID=$!

# Wait for app to start
echo "Waiting for application to start..."
sleep 10

# Run performance tests
echo "Running performance tests..."
# Example: curl -X GET http://localhost:8080/actuator/health
echo "Performance test completed"

# Stop the application
echo "Stopping application..."
kill $APP_PID || true

echo "Performance testing completed"
