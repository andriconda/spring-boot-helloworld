# Installing Make in Jenkins

The Makefile hooks require the `make` command to be available in your Jenkins environment.

## Solutions

### Option 1: Install Make on Jenkins Agent (Recommended for Bare Metal)

#### For Ubuntu/Debian-based systems:
```bash
sudo apt-get update
sudo apt-get install -y make
```

#### For RHEL/CentOS/Amazon Linux:
```bash
sudo yum install -y make
```

#### For Alpine Linux:
```bash
sudo apk add make
```

### Option 2: Use Docker Agent with Make Pre-installed (Recommended)

Update your Jenkinsfile to use a Docker agent that has make installed:

```groovy
@Library('jenkins-shared-library') _

pipeline {
    agent {
        docker {
            image 'maven:3.9-eclipse-temurin-17'
            args '-v $HOME/.m2:/root/.m2'
        }
    }
    
    stages {
        stage('Build with Shared Library') {
            steps {
                script {
                    // Call the shared library function
                    mavenBuild(
                        gitUrl: 'https://github.com/andriconda/spring-boot-helloworld.git',
                        gitBranch: 'main',
                        mavenGoals: 'clean package',
                        skipTests: true,
                        mavenTool: 'Maven',
                        cleanCache: true
                    )
                }
            }
        }
    }
}
```

**Note:** The `maven:3.9-eclipse-temurin-17` Docker image includes make by default.

### Option 3: Use Custom Docker Image

Create a Dockerfile with Maven and Make:

```dockerfile
FROM maven:3.9-eclipse-temurin-17

# Make is usually already included, but ensure it's there
RUN apt-get update && apt-get install -y make && rm -rf /var/lib/apt/lists/*

WORKDIR /app
```

Build and use this image in your Jenkinsfile.

### Option 4: Install Make via Jenkins Plugin

1. Install the **"Custom Tools Plugin"** in Jenkins
2. Go to **Manage Jenkins** → **Global Tool Configuration**
3. Add a new **Custom Tool** for make
4. Configure it to download and install make

## Current Behavior

The shared library now gracefully handles missing `make`:
- ✅ Checks if `make` is available
- ✅ Shows a warning if not found
- ✅ Skips the hook stages without failing the build
- ✅ Continues with the rest of the pipeline

## Verification

After installing make, verify it's available:

```bash
make --version
```

## Recommended Approach

**For production environments**, we recommend **Option 2 (Docker Agent)** because:
- ✅ Consistent environment across all builds
- ✅ No need to modify Jenkins agents
- ✅ Isolated dependencies
- ✅ Easy to version control

## Example: Updated Jenkinsfile with Docker

Since the shared library uses declarative pipeline internally, you'll need to modify the approach slightly. Here's the recommended pattern:

```groovy
@Library('jenkins-shared-library') _

// Use the shared library which will handle everything
mavenBuild(
    gitUrl: 'https://github.com/andriconda/spring-boot-helloworld.git',
    gitBranch: 'main',
    mavenGoals: 'clean package',
    skipTests: true,
    mavenTool: 'Maven',
    cleanCache: true
)
```

Then update the shared library to support Docker agents (optional enhancement).
