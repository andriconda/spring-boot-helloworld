# Makefile-Based Pipeline Guide

## Architecture Overview

This pipeline uses a **pure Makefile approach** where:

### Platform Engineers Control (Shared Library):
- **Mandatory stage Makefiles** in `jenkins-shared-library/stages/*/Makefile`
- **Pipeline structure** in `jenkins-shared-library/vars/makefilePipeline.groovy`
- **No app engineer modifications allowed**

### App Engineers Control (App Repo):
- **Before/After hooks** in app repo `Makefile`
- **Only hook targets**: `before-*` and `after-*`
- **Cannot modify mandatory stages**

## Directory Structure

### Shared Library Repo:
```
jenkins-shared-library/
├── stages/
│   ├── build/Makefile      # Platform-controlled build
│   ├── test/Makefile       # Platform-controlled test
│   ├── security/Makefile   # Platform-controlled security
│   └── package/Makefile    # Platform-controlled package
└── vars/
    └── makefilePipeline.groovy
```

### App Repo:
```
your-app/
├── Jenkinsfile.makefile    # Simple pipeline call
├── Makefile                # Optional before/after hooks
├── src/                    # Your code
└── pom.xml                 # Your build config
```

## Pipeline Flow

```
Setup
  ↓
Before Build (app hook) → Build (platform) → After Build (app hook)
  ↓
Before Test (app hook) → Test (platform) → After Test (app hook)
  ↓
Before Security (app hook) → Security (platform) → After Security (app hook)
  ↓
Before Package (app hook) → Package (platform) → After Package (app hook)
  ↓
Archive
```

## Mandatory Stages (Platform Controlled)

These run from shared library Makefiles. **App engineers CANNOT modify.**

### 1. Build Stage
**Location:** `jenkins-shared-library/stages/build/Makefile`

**What it does:**
- Maven: `mvn clean compile`
- Gradle: `./gradlew clean build`
- Node: `npm install && npm run build`

### 2. Test Stage
**Location:** `jenkins-shared-library/stages/test/Makefile`

**What it does:**
- Maven: `mvn test`
- Gradle: `./gradlew test`
- Node: `npm test`

### 3. Security Scan Stage
**Location:** `jenkins-shared-library/stages/security/Makefile`

**What it does:**
- Maven: `mvn dependency-check:check`
- Gradle: `./gradlew dependencyCheckAnalyze`
- Node: `npm audit`

### 4. Package Stage
**Location:** `jenkins-shared-library/stages/package/Makefile`

**What it does:**
- Maven: `mvn package -DskipTests`
- Gradle: `./gradlew assemble`
- Node: `npm pack`

## Optional Hooks (App Controlled)

App engineers can add these in their repo's `Makefile`:

| Hook | When It Runs | Use Case |
|------|--------------|----------|
| `before-build` | Before Build stage | Setup, validation |
| `after-build` | After Build stage | Verify build output |
| `before-test` | Before Test stage | Test data setup |
| `after-test` | After Test stage | Test report processing |
| `before-security` | Before Security stage | Prepare for scan |
| `after-security` | After Security stage | Process scan results |
| `before-package` | Before Package stage | Pre-package tasks |
| `after-package` | After Package stage | Verify package |

## Usage Examples

### Example 1: Minimal (No Hooks)

**Jenkinsfile.makefile:**
```groovy
@Library('jenkins-shared-library') _

makefilePipeline(
    gitUrl: 'https://github.com/your-org/your-app.git',
    gitBranch: 'main'
)
```

**No Makefile needed!** All mandatory stages run with platform defaults.

---

### Example 2: With Hooks

**Jenkinsfile.makefile:**
```groovy
@Library('jenkins-shared-library') _

makefilePipeline(
    gitUrl: 'https://github.com/your-org/your-app.git',
    gitBranch: 'main'
)
```

**Makefile:**
```makefile
.PHONY: before-build after-build after-package

before-build:
	@echo "Validating environment..."
	@java -version

after-build:
	@echo "Build completed!"
	@ls -lh target/

after-package:
	@echo "Package ready for deployment"
	@ls -lh target/*.jar
```

---

### Example 3: Full Hooks

**Makefile:**
```makefile
.PHONY: before-build after-build before-test after-test after-security after-package

before-build:
	@echo "Setting up build..."
	@java -version
	@mvn -version

after-build:
	@echo "Build artifacts:"
	@ls -lh target/

before-test:
	@echo "Setting up test database..."
	@docker-compose up -d postgres

after-test:
	@echo "Cleaning up test environment..."
	@docker-compose down

after-security:
	@echo "Processing security scan results..."
	@cat dependency-tree.txt

after-package:
	@echo "Package created:"
	@ls -lh target/*.jar
	@sha256sum target/*.jar
```

## Benefits

### For Platform Engineers:
✅ **Full control** - Mandatory stages in shared library  
✅ **Consistency** - All apps use same build/test/security/package logic  
✅ **Easy updates** - Change shared library, all apps get updates  
✅ **No app modifications** - Apps can't break mandatory stages  

### For App Engineers:
✅ **Super simple** - 3-line Jenkinsfile  
✅ **No Groovy** - Only Makefile for hooks  
✅ **Optional hooks** - Add only what you need  
✅ **Clear boundaries** - Can't accidentally break platform stages  

## Platform Engineer: Updating Mandatory Stages

To update a mandatory stage:

1. Edit the Makefile in shared library:
   ```bash
   cd jenkins-shared-library/stages/build
   vi Makefile
   ```

2. Commit and push:
   ```bash
   git add stages/build/Makefile
   git commit -m "Update build stage"
   git push
   ```

3. All apps automatically use new version on next run!

## App Engineer: Adding Hooks

To add hooks to your app:

1. Create or edit `Makefile` in your repo:
   ```bash
   vi Makefile
   ```

2. Add hook targets:
   ```makefile
   before-build:
   	@echo "My custom setup"
   
   after-build:
   	@echo "My custom validation"
   ```

3. Commit and push:
   ```bash
   git add Makefile
   git commit -m "Add build hooks"
   git push
   ```

## Migration Guide

### From existing pipeline:

1. **Copy the new Jenkinsfile:**
   ```bash
   cp Jenkinsfile.makefile Jenkinsfile
   ```

2. **Create Makefile with hooks (optional):**
   ```bash
   cp Makefile.hooks Makefile
   # Edit to add your custom hooks
   ```

3. **Test the pipeline:**
   - Commit and push
   - Run pipeline in Jenkins
   - Verify all stages work

4. **Remove old files:**
   ```bash
   git rm Jenkinsfile.old
   ```

## Troubleshooting

### Issue: "make: not found"
**Solution:** Install make in Jenkins environment:
```bash
docker exec -u root <jenkins-container> apt-get install -y make
```

### Issue: "No such file or directory: stages/build/Makefile"
**Solution:** Ensure shared library is properly loaded and stages directory exists.

### Issue: Hook not running
**Solution:** Check that:
1. Makefile exists in app repo
2. Hook target is defined (e.g., `before-build:`)
3. Target name matches exactly (case-sensitive)

## Next Steps

1. **Platform team:** Commit shared library changes
2. **App teams:** Use `Jenkinsfile.makefile` template
3. **Add hooks:** Create `Makefile` with before/after targets as needed
4. **Enjoy!** Simple, consistent, maintainable pipelines
