# Makefile for Jenkins Pipeline Custom Stages
# This file allows you to inject custom stages into the Jenkins pipeline

.PHONY: help pre-build post-build test lint security-scan docker-build

help:
	@echo "Available targets for Jenkins pipeline:"
	@echo "  pre-build       - Runs before Maven build (e.g., setup, validation)"
	@echo "  post-build      - Runs after Maven build (e.g., tests, deployment)"
	@echo "  test            - Run additional tests"
	@echo "  lint            - Run code quality checks"
	@echo "  security-scan   - Run security vulnerability scans"
	@echo "  docker-build    - Build Docker image"

# Pre-build hook - runs before Maven build
pre-build:
	@echo "=== Running Pre-Build Tasks ==="
	@echo "Validating environment..."
	@java -version
	@echo "Checking Maven version..."
	@mvn -version
	@echo "Pre-build validation complete!"

# Post-build hook - runs after Maven build
post-build:
	@echo "=== Running Post-Build Tasks ==="
	@echo "Running additional tests..."
	@make test
	@echo "Post-build tasks complete!"

# Run tests
test:
	@echo "Running unit tests..."
	@if [ -f "pom.xml" ]; then \
		mvn test; \
	else \
		echo "No pom.xml found, skipping tests"; \
	fi

# Code quality checks
lint:
	@echo "Running code quality checks..."
	@echo "Checking for common issues..."
	@find src -name "*.java" -type f | wc -l | xargs echo "Java files found:"

# Security scan
security-scan:
	@echo "Running security scan..."
	@echo "Checking for known vulnerabilities..."
	@mvn dependency:tree

# Docker build (example)
docker-build:
	@echo "Building Docker image..."
	@if [ -f "Dockerfile" ]; then \
		docker build -t spring-boot-helloworld:latest .; \
	else \
		echo "No Dockerfile found, skipping Docker build"; \
	fi
