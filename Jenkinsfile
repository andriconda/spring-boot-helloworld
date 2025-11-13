pipeline {
  agent any
  
  stages {
    stage('Checkout') {
      steps {
        git branch: 'main', url: 'file:///Users/abhishekjain/Library/CloudStorage/OneDrive-Smarsh,Inc/github/jenkins/spring-boot-hello'
      }
    }
    stage('Build') {
      steps {
        sh 'mvn -B -DskipTests clean package'
      }
    }
  }
}
