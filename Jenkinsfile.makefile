// Makefile-Based Pipeline
// Platform controls mandatory stages via shared library Makefiles
// App engineers can only add before/after hooks via app Makefile

@Library('jenkins-shared-library') _

makefilePipeline(
    gitUrl: 'https://github.com/andriconda/spring-boot-helloworld.git',
    gitBranch: 'main',
    mavenTool: 'Maven'  // Optional: Maven tool name configured in Jenkins
)

// MANDATORY STAGES (Platform controlled via shared library Makefiles):
// ✓ Build       - jenkins-shared-library/resources/stages/build/Makefile
// ✓ Test        - jenkins-shared-library/resources/stages/test/Makefile
// ✓ Security    - jenkins-shared-library/resources/stages/security/Makefile
// ✓ Package     - jenkins-shared-library/resources/stages/package/Makefile
//
// OPTIONAL HOOKS (App controlled via app repo Makefile):
// - before-build, after-build
// - before-test, after-test
// - before-security, after-security
// - before-package, after-package
