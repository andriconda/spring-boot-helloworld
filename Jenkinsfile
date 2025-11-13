pipeline {
  agent any
  
  tools {
    maven 'Maven' // Name of Maven installation in Jenkins Global Tool Configuration
  }
  
  stages {
    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/andriconda/spring-boot-helloworld.git'
      }
    }
    stage('Build') {
      steps {
        sh 'mvn -B -DskipTests clean package'
      }
    }
  }
}
