# Makefile for Jenkins Pipeline Custom Stages
# This file allows you to inject custom stages into the Jenkins pipeline

.PHONY: help before-checkout after-checkout before-clean after-clean before-build after-build before-archive after-archive test lint security-scan docker-build

help:
	@echo "Available hook targets for Jenkins pipeline:"
	@echo ""
	@echo "Stage Hooks (before/after any stage):"
	@echo "  before-checkout - Runs before checkout stage"
	@echo "  after-checkout  - Runs after checkout stage"
	@echo "  before-clean    - Runs before clean cache stage"
	@echo "  after-clean     - Runs after clean cache stage"
	@echo "  before-build    - Runs before Maven build"
	@echo "  after-build     - Runs after Maven build"
	@echo "  before-archive  - Runs before archiving artifacts"
	@echo "  after-archive   - Runs after archiving artifacts"
	@echo ""
	@echo "Custom Targets:"
	@echo "  test            - Run additional tests"
	@echo "  lint            - Run code quality checks"
	@echo "  security-scan   - Run security vulnerability scans"
	@echo "  docker-build    - Build Docker image"

# ===== STAGE HOOKS =====

# Before/After Checkout
before-checkout:
	@echo "=== Before Checkout Hook ==="
	@echo "Preparing workspace..."

after-checkout:
	@echo "=== After Checkout Hook ==="
	@echo "Workspace ready, checking files..."
	@ls -la

# Before/After Clean
before-clean:
	@echo "=== Before Clean Hook ==="
	@echo "Backing up important files if needed..."

after-clean:
	@echo "=== After Clean Hook ==="
	@echo "Clean complete!"

# Before/After Build
before-build:
	@echo "=== Before Build Hook ==="
	@echo "Validating environment..."
	@java -version
	@mvn -version

after-build:
	@echo "=== After Build Hook ==="
	@echo "Running tests and quality checks..."
	@make test
	@make security-scan
# Before/After Archive
before-archive:
	@echo "=== Before Archive Hook ==="
	@echo "Preparing artifacts for archiving..."

#after-archive:
#	@echo "=== After Archive Hook ==="
#	@echo "Artifacts archived successfully!"

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

# Docker build
docker-build:
	@echo "Building Docker image..."
	@if [ -f "Dockerfile" ]; then \
		docker build -t spring-boot-helloworld:latest . && \
		echo "Docker image built successfully: spring-boot-helloworld:latest"; \
	else \
		echo "No Dockerfile found, skipping Docker build"; \
	fi

# Docker run (for testing)
docker-run:
	@echo "Running Docker container..."
	@docker run -d -p 8080:8080 --name spring-boot-helloworld spring-boot-helloworld:latest
	@echo "Container started. Access at http://localhost:8080"

# Docker stop
docker-stop:
	@echo "Stopping Docker container..."
	@docker stop spring-boot-helloworld || true
	@docker rm spring-boot-helloworld || true

# Docker push (example - update with your registry)
docker-push:
	@echo "Pushing Docker image..."
	@docker tag spring-boot-helloworld:latest your-registry/spring-boot-helloworld:latest
	@docker push your-registry/spring-boot-helloworld:latest
