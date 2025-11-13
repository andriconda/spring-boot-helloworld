#!/bin/bash
# Custom Stage: Code Quality
# Runs after Build stage

set -e

echo "=== Code Quality Checks ==="

# Check code style
echo "Running checkstyle..."
mvn checkstyle:check || echo "Checkstyle warnings found"

# Check for code smells
echo "Running PMD..."
mvn pmd:check || echo "PMD warnings found"

# Check for bugs
echo "Running SpotBugs..."
mvn spotbugs:check || echo "SpotBugs warnings found"

echo "Code quality checks completed"
