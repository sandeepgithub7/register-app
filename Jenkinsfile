pipeline {
    agent any
    
    tools {
        maven 'maven3'
        jdk 'jdk17'
    }
    
    environment {
        APP_NAME = "register-app-pipeline"
        RELEASE = "1.0.0"
        DOCKER_USER = "sandeeepdocker7"
        DOCKER_PASS = 'docker-cred'
        IMAGE_NAME = "${DOCKER_USER}" + "/" + "${APP_NAME}"
        IMAGE_TAG = "${RELEASE}-${BUILD_NUMBER}"
        JENKINS_API_TOKEN = credentials("JENKINS_API_TOKEN")
	    
    }
    

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }
        
         stage('Git Checkout') {
            steps {
               git branch: 'main', changelog: false, poll: false, url: 'https://github.com/sandeepgithub7/register-app.git' 
            }
        }
        
         stage('Build Code') {
            steps {
                sh"mvn clean compile"
            }
        }
        
        stage('Test Code') {
            steps {
                sh"mvn test"
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                script{
                    withSonarQubeEnv(credentialsId: 'sonar-cred') {
                        sh "mvn sonar:sonar"
                    }
                }
            }
        }
        
        stage('Quality Gate') {
            steps {
                script{
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-cred'
                }
            }
        }
        
        
         stage('Docker Build & Push') {
            steps {
                script{
                    docker.withRegistry('',DOCKER_PASS) {
                        docker_image = docker.build "${IMAGE_NAME}"
                }
                
                    docker.withRegistry('',DOCKER_PASS) {
                        docker_image.push("${IMAGE_TAG}")
                        docker_image.push('latest')
                    }
                }
            }
        }
        
         stage("Trivy Scan") {
           steps {
               script {
	            sh ('docker run -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image sandeeepdocker7/register-app-pipeline:latest --no-progress --scanners vuln  --exit-code 0 --severity HIGH,CRITICAL --format table')
               }
           }
       }
       
         stage ('Cleanup Artifact') {
           steps {
               script {
                    sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker rmi ${IMAGE_NAME}:latest"
               }
          }
        }
       
         stage("Trigger CD Pipeline") {
            steps {
                script {
                    sh "curl -v -k --user sandeep:${JENKINS_API_TOKEN} -X POST -H 'cache-control: no-cache' -H 'content-type: application/x-www-form-urlencoded' --data 'IMAGE_TAG=${IMAGE_TAG}' 'http://54.90.25.133:8080//job/CD-pipeline/buildWithParameters?token=gitops-token'"
                }
            }
        }
    }
}
