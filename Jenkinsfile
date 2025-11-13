@Library('jenkins-shared-library') _

mavenBuild(
    gitUrl: 'https://github.com/andriconda/spring-boot-helloworld.git',
    gitBranch: 'main',
    mavenGoals: 'clean package',
    skipTests: true,
    mavenTool: 'Maven',
    cleanCache: true
)
