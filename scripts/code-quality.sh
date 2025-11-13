#!/bin/bash
# Custom Stage: Code Quality
# Runs after Build stage

set -e

echo "=== Code Quality Checks ==="

# Check code style
echo "Running checkstyle..."
mvn checkstyle:check

# Check for code smells
echo "Running PMD..."
mvn pmd:check

# Check for bugs
echo "Running SpotBugs..."
mvn spotbugs:check

echo "Code quality checks completed"
