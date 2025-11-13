# Enhanced Makefile Hooks - Before/After Any Stage

## ✅ What Changed

The shared library now supports hooks **before and after EVERY stage**, not just build!

### New Pipeline Flow

```
Before Checkout → Checkout → After Checkout
    ↓
Before Clean → Clean Cache → After Clean
    ↓
Before Build → Build → After Build
    ↓
Before Archive → Archive → After Archive
```

## Available Hook Targets

| Hook Target | When It Runs | Common Use Cases |
|------------|--------------|------------------|
| `before-checkout` | Before git checkout | Workspace prep, cleanup |
| `after-checkout` | After git checkout | File validation, dependency checks |
| `before-clean` | Before cache cleaning | Backup important files |
| `after-clean` | After cache cleaning | Verification, logging |
| `before-build` | Before Maven build | Environment validation, code generation |
| `after-build` | After Maven build | Tests, quality checks, security scans |
| `before-archive` | Before archiving | Artifact preparation, signing |
| `after-archive` | After archiving | Deployment, notifications |

## Example Use Cases

### 1. Environment Validation

```makefile
before-build:
	@echo "Checking Java version..."
	@java -version
	@echo "Checking Maven version..."
	@mvn -version
```

### 2. Run Tests After Build

```makefile
after-build:
	@echo "Running unit tests..."
	@mvn test
	@echo "Running integration tests..."
	@mvn verify
```

### 3. Security Scanning

```makefile
after-build:
	@echo "Scanning for vulnerabilities..."
	@mvn dependency:tree
	@mvn dependency-check:check
```

### 4. Docker Image Build

```makefile
after-archive:
	@echo "Building Docker image..."
	@docker build -t myapp:latest .
	@docker push myapp:latest
```

### 5. Deployment

```makefile
after-archive:
	@echo "Deploying to staging..."
	@kubectl apply -f k8s/staging/
```

## How It Works

1. **Automatic Detection**: The pipeline checks if Makefile exists
2. **Target Check**: For each stage, checks if before/after hooks exist
3. **Execution**: Runs the hook if the target is defined
4. **Graceful Skip**: If hook doesn't exist, continues without error

## Benefits

- ✅ **Granular Control**: Hook into any stage
- ✅ **Flexible**: Define only the hooks you need
- ✅ **Standardized**: Same interface across all projects
- ✅ **Optional**: All hooks are optional
- ✅ **No Jenkinsfile Changes**: Customize via Makefile only

## Testing Locally

Test your Makefile hooks before committing:

```bash
make help
make before-build
make after-build
```

## Next Steps

1. **Commit shared library changes:**
   ```bash
   cd /Users/abhishekjain/Documents/GitHub/jenkins-shared-library
   git add .
   git commit -m "Add before/after hooks for all pipeline stages"
   git push origin main
   ```

2. **Commit project changes:**
   ```bash
   cd /Users/abhishekjain/Documents/GitHub/spring-boot-helloworld
   git add Makefile MAKEFILE_USAGE.md HOOKS_SUMMARY.md
   git commit -m "Add comprehensive Makefile hooks for all stages"
   git push origin main
   ```

3. **Run your pipeline** and see all the hooks in action!

## Example Output

When you run the pipeline, you'll see:

```
[Before Checkout] Running before-checkout hook from Makefile
[Checkout] Checking out main from https://github.com/...
[After Checkout] Running after-checkout hook from Makefile
[Before Build] Running before-build hook from Makefile
[Build] Executing: mvn -B -DskipTests clean package
[After Build] Running after-build hook from Makefile
[Archive] Archiving artifacts
```
