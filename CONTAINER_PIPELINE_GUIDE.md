## Container-Based Pipeline Guide

## Overview

The **Container-Based Pipeline** is the most modern and portable approach:

### ✅ **NO TOOLS REQUIRED ON JENKINS!**
- No Maven installation
- No Java installation  
- No Make installation
- No Node.js installation

### ✅ **Everything Runs in Containers**
- Build → `maven:3.9-eclipse-temurin-17`
- Test → `maven:3.9-eclipse-temurin-17`
- Security → `maven:3.9-eclipse-temurin-17`
- Package → `maven:3.9-eclipse-temurin-17`
- Docker → `docker:24-cli`

### ✅ **Benefits**
- **Portable:** Works on any Jenkins with Docker
- **Consistent:** Same environment every time
- **Easy updates:** Change container image, not Jenkins
- **Isolated:** No tool conflicts
- **Fast setup:** Just need Docker on Jenkins

## Architecture

### Platform Engineers Control:
- **Container images** for each stage
- **Commands** executed in containers
- **Pipeline structure**

### App Engineers Control:
- **Optional hooks** via `pipeline-hooks.sh`
- **Container image overrides** (optional)

### App Engineers Cannot:
- Modify mandatory stages
- Skip mandatory stages
- Change pipeline structure

## File Structure

```
your-app/
├── Jenkinsfile.container    # 3-line pipeline config
├── pipeline-hooks.sh        # Optional before/after hooks
├── Dockerfile               # Optional Docker build
├── src/                     # Your code
└── pom.xml                  # Your build config
```

## Usage

### Minimal Setup (No Hooks)

**Jenkinsfile.container:**
```groovy
@Library('jenkins-shared-library') _

containerPipeline(
    gitUrl: 'https://github.com/your-org/your-app.git',
    gitBranch: 'main'
)
```

**That's it!** No other files needed. All stages run with defaults.

---

### With Hooks

**Jenkinsfile.container:**
```groovy
@Library('jenkins-shared-library') _

containerPipeline(
    gitUrl: 'https://github.com/your-org/your-app.git',
    gitBranch: 'main'
)
```

**pipeline-hooks.sh:**
```bash
#!/bin/bash

before_build() {
    echo "Validating environment..."
    java -version
}

after_build() {
    echo "Build completed!"
    ls -lh target/
}
```

---

### With Custom Container Images

**Jenkinsfile.container:**
```groovy
@Library('jenkins-shared-library') _

containerPipeline(
    gitUrl: 'https://github.com/your-org/your-app.git',
    gitBranch: 'main',
    
    // Use custom images
    buildImage: 'maven:3.9-eclipse-temurin-21',  // Java 21
    testImage: 'maven:3.9-eclipse-temurin-21',
    dockerImage: 'docker:25-cli'
)
```

## Pipeline Flow

```
Setup
  ↓
[Container: maven:3.9] before_build() → Build → after_build()
  ↓
[Container: maven:3.9] before_test() → Test → after_test()
  ↓
[Container: maven:3.9] before_security() → Security → after_security()
  ↓
[Container: maven:3.9] before_package() → Package → after_package()
  ↓
[Container: docker:24] Docker Build (if Dockerfile exists)
  ↓
Archive
```

## Mandatory Stages

### 1. Build
**Container:** `maven:3.9-eclipse-temurin-17`  
**Command:** `mvn clean compile`  
**Hooks:** `before_build()`, `after_build()`

### 2. Test
**Container:** `maven:3.9-eclipse-temurin-17`  
**Command:** `mvn test`  
**Hooks:** `before_test()`, `after_test()`

### 3. Security Scan
**Container:** `maven:3.9-eclipse-temurin-17`  
**Command:** `mvn dependency:tree`  
**Hooks:** `before_security()`, `after_security()`

### 4. Package
**Container:** `maven:3.9-eclipse-temurin-17`  
**Command:** `mvn package -DskipTests`  
**Hooks:** `before_package()`, `after_package()`

### 5. Docker Build (Optional)
**Container:** `docker:24-cli`  
**Command:** `docker build`  
**Condition:** Only if `Dockerfile` exists

## Optional Hooks

Create `pipeline-hooks.sh` with bash functions:

```bash
#!/bin/bash

# Build hooks
before_build() {
    echo "Custom pre-build tasks"
}

after_build() {
    echo "Custom post-build tasks"
}

# Test hooks
before_test() {
    echo "Setup test environment"
}

after_test() {
    echo "Process test results"
}

# Security hooks
before_security() {
    echo "Prepare for security scan"
}

after_security() {
    echo "Process security results"
}

# Package hooks
before_package() {
    echo "Pre-package tasks"
}

after_package() {
    echo "Post-package tasks"
}
```

**All hooks are optional!** Only implement what you need.

## Comparison with Other Pipelines

| Feature | mavenBuild | makefilePipeline | containerPipeline |
|---------|------------|------------------|-------------------|
| **Tools on Jenkins** | Maven, Java | Make, Maven, Java | Only Docker |
| **Hooks** | Makefile | Makefile | Shell script |
| **Portability** | Medium | Medium | **High** |
| **Setup complexity** | Medium | Medium | **Low** |
| **Consistency** | Medium | Medium | **High** |
| **Best for** | Maven projects | Multi-language | **Any project** |

## Jenkins Requirements

### Minimal Requirements:
- ✅ Docker installed on Jenkins
- ✅ Docker socket accessible
- ✅ That's it!

### No Need For:
- ❌ Maven
- ❌ Java
- ❌ Make
- ❌ Node.js
- ❌ Gradle

## Maven Cache

The pipeline automatically uses a Docker volume for Maven cache:

```groovy
docker.image('maven:3.9').inside("-v maven-repo:/root/.m2") {
    // Maven commands here
}
```

This speeds up builds by caching dependencies between runs.

## Docker-in-Docker

For the Docker Build stage, the pipeline mounts the Docker socket:

```groovy
docker.image('docker:24-cli').inside("-v /var/run/docker.sock:/var/run/docker.sock") {
    sh 'docker build -t myapp:latest .'
}
```

This allows building Docker images from within a container.

## Examples

### Example 1: Java 21 Project

**Jenkinsfile.container:**
```groovy
@Library('jenkins-shared-library') _

containerPipeline(
    gitUrl: 'https://github.com/your-org/java21-app.git',
    gitBranch: 'main',
    buildImage: 'maven:3.9-eclipse-temurin-21',
    testImage: 'maven:3.9-eclipse-temurin-21'
)
```

### Example 2: Gradle Project

**Jenkinsfile.container:**
```groovy
@Library('jenkins-shared-library') _

containerPipeline(
    gitUrl: 'https://github.com/your-org/gradle-app.git',
    gitBranch: 'main',
    buildImage: 'gradle:8-jdk17',
    testImage: 'gradle:8-jdk17'
)
```

The platform stages will automatically detect `build.gradle` and use Gradle commands.

### Example 3: Node.js Project

**Jenkinsfile.container:**
```groovy
@Library('jenkins-shared-library') _

containerPipeline(
    gitUrl: 'https://github.com/your-org/node-app.git',
    gitBranch: 'main',
    buildImage: 'node:20-alpine',
    testImage: 'node:20-alpine'
)
```

The platform stages will automatically detect `package.json` and use npm commands.

### Example 4: With All Hooks

**pipeline-hooks.sh:**
```bash
#!/bin/bash

before_build() {
    echo "Checking code style..."
    mvn checkstyle:check
}

after_build() {
    echo "Generating build report..."
    ls -lh target/
}

before_test() {
    echo "Starting test database..."
    # Could start a sidecar container
}

after_test() {
    echo "Publishing test results..."
    # Could send to test reporting service
}

after_security() {
    echo "Checking for critical vulnerabilities..."
    cat dependency-tree.txt
}

after_package() {
    echo "Calculating package checksum..."
    sha256sum target/*.jar
}
```

## Migration Guide

### From mavenBuild:

1. **Copy Jenkinsfile template:**
   ```bash
   cp Jenkinsfile.container Jenkinsfile
   ```

2. **Convert Makefile hooks to pipeline-hooks.sh:**
   ```bash
   # Makefile
   before-build:
       @echo "Hello"
   
   # pipeline-hooks.sh
   before_build() {
       echo "Hello"
   }
   ```

3. **Test and commit:**
   ```bash
   git add Jenkinsfile pipeline-hooks.sh
   git commit -m "Switch to container-based pipeline"
   git push
   ```

### From makefilePipeline:

Same as above - convert Makefile targets to bash functions.

## Troubleshooting

### Issue: Docker not available
**Solution:** Install Docker on Jenkins agent:
```bash
docker --version  # Should work
```

### Issue: Permission denied on Docker socket
**Solution:** Add Jenkins user to docker group:
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Issue: Maven cache not working
**Solution:** Check Docker volume:
```bash
docker volume ls | grep maven-repo
docker volume inspect maven-repo
```

### Issue: Hook not running
**Solution:** Check that:
1. `pipeline-hooks.sh` exists
2. Function is defined (e.g., `before_build()`)
3. File is executable: `chmod +x pipeline-hooks.sh`

## Best Practices

### 1. Use Official Images
```groovy
buildImage: 'maven:3.9-eclipse-temurin-17'  // ✓ Official
buildImage: 'random/maven-custom'           // ✗ Unknown source
```

### 2. Pin Image Versions
```groovy
buildImage: 'maven:3.9-eclipse-temurin-17'  // ✓ Specific version
buildImage: 'maven:latest'                   // ✗ Unpredictable
```

### 3. Keep Hooks Simple
```bash
after_build() {
    echo "Build done"
    ls -lh target/
}  # ✓ Simple and fast

after_build() {
    # 100 lines of complex logic
}  # ✗ Too complex, move to separate script
```

### 4. Use Maven Cache
The pipeline automatically uses Maven cache volume. No action needed!

## Platform Engineers: Updating Stages

To update a mandatory stage for all apps:

**Edit `vars/containerPipeline.groovy`:**
```groovy
stage('Build') {
    steps {
        script {
            docker.image(buildImage).inside("-v ${mavenCache}:/root/.m2") {
                sh '''
                    mvn clean compile -Pnew-profile  // Add new flag
                '''
            }
        }
    }
}
```

Commit and push - all apps get the update!

## Next Steps

1. ✅ `Jenkinsfile.container` created
2. ✅ `pipeline-hooks.sh` created
3. 🔄 Test: Rename `Jenkinsfile.container` to `Jenkinsfile`
4. 🔄 Run pipeline in Jenkins
5. 🔄 Add hooks as needed

This is the **most portable and modern** pipeline approach! 🚀🐳
