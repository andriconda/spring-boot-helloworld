# Custom Stages Guide

## Overview

App engineers can now add **named custom stages** with their own containers, not just before/after hooks!

## Three Ways to Extend the Pipeline

### 1. Before/After Hooks (Simple)
Quick hooks using bash functions.

```bash
# pipeline-hooks.sh
before_build() {
    echo "Quick pre-build task"
}
```

### 2. Custom Stages (Named, Flexible) ⭐ **NEW**
Full stages with custom names and containers.

```groovy
// Jenkinsfile
customStages: [
    'Code Quality': [
        after: 'build',
        container: 'maven:3.9',
        scriptFile: 'scripts/code-quality.sh'
    ]
]
```

### 3. Hybrid (Both)
Use both approaches together!

## Custom Stages Syntax

### Basic Structure

```groovy
customStages: [
    'Stage Name': [
        after: 'build|package',      // Where to insert
        container: 'image:tag',       // Container to use
        scriptFile: 'path/to/script'  // Script to run
    ]
]
```

### Options

| Field | Required | Description |
|-------|----------|-------------|
| `after` | Yes | Insert after: `'build'`, `'test'`, `'security'`, or `'package'` |
| `container` | No | Container image (default: platform image) |
| `scriptFile` | One of | Path to script file in repo |
| `script` | One of | Inline script |

### Runtime Decision

Custom stages are **executed dynamically at runtime** based on the `after` value. The pipeline doesn't have hardcoded insertion points - it decides at runtime which custom stages to execute after each mandatory stage.

## Examples

### Example 1: Code Quality After Build

**Jenkinsfile:**
```groovy
@Library('jenkins-shared-library') _

containerPipeline(
    gitUrl: 'https://github.com/org/app.git',
    gitBranch: 'main',
    customStages: [
        'Code Quality': [
            after: 'build',
            container: 'maven:3.9-eclipse-temurin-17',
            scriptFile: 'scripts/code-quality.sh'
        ]
    ]
)
```

**scripts/code-quality.sh:**
```bash
#!/bin/bash
set -e
echo "Running code quality checks..."
mvn checkstyle:check
mvn pmd:check
```

### Example 2: Multiple Stages After Package

**Jenkinsfile:**
```groovy
customStages: [
    'Performance Test': [
        after: 'package',
        container: 'maven:3.9',
        scriptFile: 'scripts/performance-test.sh'
    ],
    'Deploy to Staging': [
        after: 'package',
        container: 'bitnami/kubectl:latest',
        script: '''
            kubectl apply -f k8s/staging/
            kubectl rollout status deployment/myapp
        '''
    ],
    'Smoke Test': [
        after: 'package',
        container: 'curlimages/curl:latest',
        script: 'curl -f http://staging.example.com/health'
    ]
]
```

### Example 3: Inline Script

**Jenkinsfile:**
```groovy
customStages: [
    'Notify Slack': [
        after: 'build',
        container: 'curlimages/curl:latest',
        script: '''
            curl -X POST https://hooks.slack.com/services/YOUR/WEBHOOK \
              -d '{"text":"Build completed!"}'
        '''
    ]
]
```

### Example 4: Using Different Containers

**Jenkinsfile:**
```groovy
customStages: [
    'Python Analysis': [
        after: 'build',
        container: 'python:3.11-slim',
        script: '''
            pip install pylint
            pylint src/
        '''
    ],
    'Node.js Build': [
        after: 'build',
        container: 'node:20-alpine',
        script: '''
            npm install
            npm run build:frontend
        '''
    ]
]
```

## Pipeline Flow with Custom Stages

```
Setup
  ↓
Before Build → Build → After Build
  ↓
[Custom: Code Quality]        ← Your custom stage
  ↓
Before Test → Test → After Test
  ↓
Before Security → Security → After Security
  ↓
Before Package → Package → After Package
  ↓
[Custom: Performance Test]    ← Your custom stage
[Custom: Deploy to Staging]   ← Your custom stage
[Custom: Smoke Test]           ← Your custom stage
  ↓
Docker Build
  ↓
Archive
```

## Comparison: Hooks vs Custom Stages

| Feature | Before/After Hooks | Custom Stages |
|---------|-------------------|---------------|
| **Naming** | Fixed (before_build, after_build) | **Custom names** |
| **Location** | pipeline-hooks.sh | **Jenkinsfile** |
| **Container** | Can customize | **Can customize** |
| **Script** | Bash function | **File or inline** |
| **Visibility** | Less visible | **Shows as stage** |
| **Best for** | Quick hooks | **Full stages** |

## When to Use What

### Use Before/After Hooks When:
- ✅ Quick, simple tasks
- ✅ Tightly coupled to mandatory stage
- ✅ Don't need custom container
- ✅ Example: Print version, check files

### Use Custom Stages When:
- ✅ Complex, standalone tasks
- ✅ Need custom container
- ✅ Want clear stage name in UI
- ✅ Example: Code quality, deployment, smoke tests

## Complete Example

**Jenkinsfile:**
```groovy
@Library('jenkins-shared-library') _

containerPipeline(
    gitUrl: 'https://github.com/org/app.git',
    gitBranch: 'main',
    
    // Custom stages with names
    customStages: [
        'Code Quality': [
            after: 'build',
            container: 'maven:3.9',
            scriptFile: 'scripts/code-quality.sh'
        ],
        'Deploy to Staging': [
            after: 'package',
            container: 'bitnami/kubectl:latest',
            scriptFile: 'scripts/deploy-staging.sh'
        ],
        'Smoke Test': [
            after: 'package',
            container: 'curlimages/curl:latest',
            scriptFile: 'scripts/smoke-test.sh'
        ]
    ],
    
    // Quick hooks
    hookContainers: [
        after_build: 'alpine:latest'
    ]
)
```

**pipeline-hooks.sh:**
```bash
#!/bin/bash

# Quick hook
after_build() {
    echo "Build artifacts:"
    ls -lh target/
}
```

**scripts/code-quality.sh:**
```bash
#!/bin/bash
set -e
mvn checkstyle:check
mvn pmd:check
```

**scripts/deploy-staging.sh:**
```bash
#!/bin/bash
set -e
kubectl apply -f k8s/staging/
kubectl rollout status deployment/myapp
```

**scripts/smoke-test.sh:**
```bash
#!/bin/bash
set -e
curl -f http://staging.example.com/health
curl -f http://staging.example.com/api/status
```

## Best Practices

### 1. Use Descriptive Names
```groovy
'Code Quality Analysis'  // ✓ Clear
'Quality'                // ✗ Vague
```

### 2. Keep Scripts in Repo
```groovy
scriptFile: 'scripts/deploy.sh'  // ✓ Version controlled
script: '...'                     // ✗ Hard to maintain
```

### 3. Use Appropriate Containers
```groovy
container: 'bitnami/kubectl:latest'  // ✓ Specific tool
container: 'ubuntu:latest'           // ✗ Too generic
```

### 4. Make Scripts Executable
```bash
chmod +x scripts/*.sh
git add scripts/
```

### 5. Handle Errors
```bash
#!/bin/bash
set -e  # Exit on error
# Your script
```

## Troubleshooting

### Issue: Script not found
**Solution:** Check path is relative to repo root
```groovy
scriptFile: 'scripts/deploy.sh'  // ✓ From repo root
scriptFile: './scripts/deploy.sh' // ✗ May not work
```

### Issue: Permission denied
**Solution:** Make script executable
```bash
chmod +x scripts/deploy.sh
git add scripts/deploy.sh
git commit -m "Make script executable"
```

### Issue: Container not found
**Solution:** Use full image name with tag
```groovy
container: 'maven:3.9-eclipse-temurin-17'  // ✓ Full name
container: 'maven'                          // ✗ No tag
```

## Migration from Makefile

### Before (Makefile):
```makefile
code-quality:
	mvn checkstyle:check
	mvn pmd:check
```

### After (Custom Stage):
```groovy
customStages: [
    'Code Quality': [
        after: 'build',
        scriptFile: 'scripts/code-quality.sh'
    ]
]
```

```bash
# scripts/code-quality.sh
#!/bin/bash
mvn checkstyle:check
mvn pmd:check
```

## Summary

**Custom stages give you:**
- ✅ **Named stages** in Jenkins UI
- ✅ **Custom containers** per stage
- ✅ **Flexible placement** (after build or package)
- ✅ **Clear separation** from mandatory stages
- ✅ **Version controlled** scripts

**Use them for:**
- Code quality checks
- Performance testing
- Deployment
- Smoke testing
- Notifications
- Any custom workflow!

🚀 **Now you have maximum flexibility while platform maintains control!**
