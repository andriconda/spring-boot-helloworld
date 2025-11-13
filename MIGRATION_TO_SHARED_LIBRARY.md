# Migration to Separate Shared Library Repository

The Jenkins shared library has been moved to a separate repository for better reusability across projects.

## What Changed

### Before
- Shared library was in `vars/` directory within this project
- Library name: `spring-boot-shared-lib`
- Only usable by this project

### After
- Shared library is in separate repository: `jenkins-shared-library`
- Library name: `jenkins-shared-library`
- Can be used by any project
- Added `cleanCache` parameter for optional cache cleaning

## New Repository Location

**Repository:** `/Users/abhishekjain/Documents/GitHub/jenkins-shared-library`

## Next Steps

### 1. Create GitHub Repository

Create a new repository on GitHub:
```bash
# Repository name: jenkins-shared-library
# URL: https://github.com/andriconda/jenkins-shared-library.git
```

### 2. Push the Shared Library

```bash
cd /Users/abhishekjain/Documents/GitHub/jenkins-shared-library
git remote add origin https://github.com/andriconda/jenkins-shared-library.git
git commit -m "Initial Jenkins shared library setup"
git push -u origin main
```

### 3. Configure in Jenkins

1. Go to **Manage Jenkins** → **System**
2. Scroll to **Global Pipeline Libraries**
3. Click **Add** and configure:
   - **Name**: `jenkins-shared-library`
   - **Default version**: `main`
   - **Retrieval method**: Modern SCM → Git
   - **Project Repository**: `https://github.com/andriconda/jenkins-shared-library.git`
4. Save

### 4. Clean Up This Repository (Optional)

Remove the old shared library files from this project:
```bash
cd /Users/abhishekjain/Documents/GitHub/spring-boot-helloworld
rm -rf vars/
rm SHARED_LIBRARY_README.md
git add .
git commit -m "Remove local shared library, now using external library"
git push origin main
```

### 5. Update and Test

```bash
cd /Users/abhishekjain/Documents/GitHub/spring-boot-helloworld
git add Jenkinsfile MIGRATION_TO_SHARED_LIBRARY.md
git commit -m "Update Jenkinsfile to use external shared library"
git push origin main
```

Then run your Jenkins pipeline to test!

## Benefits

- ✅ **Reusability**: Use the same library across multiple projects
- ✅ **Maintainability**: Update pipeline logic in one place
- ✅ **Version Control**: Different projects can use different library versions
- ✅ **Separation of Concerns**: Application code separate from pipeline code
