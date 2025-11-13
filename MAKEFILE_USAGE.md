# Custom Pipeline Stages via Makefile

This project uses a Makefile to inject custom stages into the Jenkins pipeline.

## How It Works

The Jenkins shared library automatically detects the `Makefile` and runs hook targets before and after each stage of the pipeline.

### Pipeline Flow with Hooks

1. **Before Checkout** - Runs `make before-checkout` (if exists)
2. **Checkout** - Clone the repository
3. **After Checkout** - Runs `make after-checkout` (if exists)
4. **Before Clean Cache** - Runs `make before-clean` (if exists)
5. **Clean Cache** - Clean Maven cache (if enabled)
6. **After Clean Cache** - Runs `make after-clean` (if exists)
7. **Before Build** - Runs `make before-build` (if exists)
8. **Build** - Maven build
9. **After Build** - Runs `make after-build` (if exists)
10. **Before Archive** - Runs `make before-archive` (if exists)
11. **Archive** - Archive build artifacts
12. **After Archive** - Runs `make after-archive` (if exists)

## Available Makefile Hook Targets

### Before/After Checkout
- **`before-checkout`** - Runs before git checkout
  - Use for: workspace preparation, cleanup
- **`after-checkout`** - Runs after git checkout
  - Use for: file validation, dependency checks

### Before/After Clean Cache
- **`before-clean`** - Runs before cache cleaning
  - Use for: backing up important files
- **`after-clean`** - Runs after cache cleaning
  - Use for: verification, logging

### Before/After Build
- **`before-build`** - Runs before Maven build
  - Use for: environment validation, code generation
- **`after-build`** - Runs after Maven build
  - Use for: tests, quality checks, security scans

### Before/After Archive
- **`before-archive`** - Runs before artifact archiving
  - Use for: artifact preparation, signing
- **`after-archive`** - Runs after artifact archiving
  - Use for: deployment, notifications

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
