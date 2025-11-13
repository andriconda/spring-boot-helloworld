# Jenkins Shared Library Setup

This repository now contains a Jenkins Shared Library in the `vars/` directory.

## Directory Structure

```
.
├── Jenkinsfile              # Uses the shared library
├── vars/
│   ├── mavenBuild.groovy   # Shared library pipeline
│   └── mavenBuild.txt      # Documentation
└── src/                     # Your application source
```

## Setup Instructions

### Step 1: Configure Shared Library in Jenkins

1. Go to **Jenkins Dashboard** → **Manage Jenkins** → **System** (or **Configure System**)
2. Scroll down to **Global Pipeline Libraries** section
3. Click **Add**
4. Configure:
   - **Name**: `spring-boot-shared-lib` (must match the name in Jenkinsfile)
   - **Default version**: `main` (or your default branch)
   - **Retrieval method**: Select **Modern SCM**
   - **Source Code Management**: Select **Git**
   - **Project Repository**: `https://github.com/andriconda/spring-boot-helloworld.git`
   - **Behaviors**: Add "Discover branches" if needed
5. **Save** the configuration

### Step 2: Ensure Maven is Configured

Make sure Maven is configured in **Manage Jenkins** → **Global Tool Configuration** with the name `Maven`.

### Step 3: Run Your Pipeline

Commit and push the changes, then run your Jenkins job. The pipeline will now use the shared library.

## Usage

### Basic Usage (with defaults)

```groovy
@Library('spring-boot-shared-lib') _

mavenBuild()
```

### Custom Configuration

```groovy
@Library('spring-boot-shared-lib') _

mavenBuild(
    gitUrl: 'https://github.com/your-org/your-repo.git',
    gitBranch: 'develop',
    mavenGoals: 'clean install',
    skipTests: false,
    mavenTool: 'Maven'
)
```

## Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `gitUrl` | Git repository URL | `https://github.com/andriconda/spring-boot-helloworld.git` |
| `gitBranch` | Git branch to checkout | `main` |
| `mavenGoals` | Maven goals to execute | `clean package` |
| `skipTests` | Skip tests during build | `true` |
| `mavenTool` | Name of Maven tool in Jenkins | `Maven` |

## Benefits

- **Reusability**: Use the same pipeline logic across multiple projects
- **Maintainability**: Update pipeline logic in one place
- **Consistency**: Ensure all projects follow the same build process
- **Flexibility**: Easily customize behavior with parameters

## Adding More Shared Libraries

To add more shared library functions, create new `.groovy` files in the `vars/` directory. Each file becomes a global function available in your Jenkinsfiles.
