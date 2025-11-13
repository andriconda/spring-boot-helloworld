# Custom Pipeline Stages via Makefile

This project uses a Makefile to inject custom stages into the Jenkins pipeline.

## How It Works

The Jenkins shared library automatically detects the `Makefile` and runs specific targets at different stages of the pipeline:

### Pipeline Flow

1. **Checkout** - Clone the repository
2. **Clean Cache** - Clean Maven cache (if enabled)
3. **Pre-Build Hook** - Runs `make pre-build` (if target exists)
4. **Build** - Maven build
5. **Post-Build Hook** - Runs `make post-build` (if target exists)
6. **Archive** - Archive build artifacts

## Available Makefile Targets

### Standard Hooks

- **`pre-build`** - Runs before Maven build
  - Use for: validation, environment checks, setup tasks
  
- **`post-build`** - Runs after Maven build
  - Use for: additional tests, security scans, deployment

### Custom Targets

You can define any custom targets and call them from the hooks:

- **`test`** - Run additional tests
- **`lint`** - Code quality checks
- **`security-scan`** - Security vulnerability scanning
- **`docker-build`** - Build Docker images

## Usage Examples

### View Available Targets

```bash
make help
```

### Run Locally

Test your Makefile targets locally before committing:

```bash
make pre-build
make post-build
make test
```

### Customize for Your Project

Edit the `Makefile` to add your own custom stages:

```makefile
.PHONY: deploy

deploy:
	@echo "Deploying application..."
	@kubectl apply -f k8s/deployment.yaml

post-build: test deploy
	@echo "Post-build complete!"
```

## Benefits

- ✅ **Standardized Interface**: All projects use the same Makefile convention
- ✅ **Flexible**: Each project can define its own custom logic
- ✅ **Optional**: Stages only run if targets are defined
- ✅ **No Jenkinsfile Changes**: Customize pipeline without modifying Jenkinsfile
- ✅ **Local Testing**: Test pipeline stages locally before pushing

## Example: Adding a New Stage

1. Edit `Makefile`
2. Add your custom target:
   ```makefile
   .PHONY: integration-test
   
   integration-test:
   	@echo "Running integration tests..."
   	@mvn verify -Pintegration-tests
   ```
3. Call it from `post-build`:
   ```makefile
   post-build: test integration-test
   	@echo "All tests passed!"
   ```
4. Commit and push - Jenkins will automatically run it!

## Disabling Hooks

To temporarily disable a hook, simply comment it out or rename the target:

```makefile
# pre-build:  # Disabled
pre-build-disabled:
	@echo "This won't run"
```
