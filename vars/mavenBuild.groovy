#!/usr/bin/env groovy

def call(Map config = [:]) {
    def gitUrl = config.gitUrl ?: 'https://github.com/andriconda/spring-boot-helloworld.git'
    def gitBranch = config.gitBranch ?: 'main'
    def mavenGoals = config.mavenGoals ?: 'clean package'
    def skipTests = config.skipTests ?: true
    def mavenTool = config.mavenTool ?: 'Maven'
    
    pipeline {
        agent any
        
        tools {
            maven "${mavenTool}"
        }
        
        stages {
            stage('Checkout') {
                steps {
                    script {
                        echo "Checking out ${gitBranch} from ${gitUrl}"
                        git branch: gitBranch, url: gitUrl
                    }
                }
            }
            
            stage('Build') {
                steps {
                    script {
                        def mvnCommand = "mvn -B"
                        if (skipTests) {
                            mvnCommand += " -DskipTests"
                        }
                        mvnCommand += " ${mavenGoals}"
                        
                        echo "Executing: ${mvnCommand}"
                        sh mvnCommand
                    }
                }
            }
            
            stage('Archive') {
                steps {
                    script {
                        echo "Archiving artifacts"
                        archiveArtifacts artifacts: '**/target/*.jar', allowEmptyArchive: true
                    }
                }
            }
        }
        
        post {
            success {
                echo "Build completed successfully!"
            }
            failure {
                echo "Build failed!"
            }
            always {
                cleanWs()
            }
        }
    }
}
