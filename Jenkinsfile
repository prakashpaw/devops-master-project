pipeline {
    agent any

    environment {
        // Use the ID you set in Jenkins Credentials
        AWS_CREDS = credentials('aws-creds')
        DOCKER_HUB_USER = "pawarpr" // Change this
        APP_NAME = "devops-java-app"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                dir('java-app') {
                    sh 'mvn clean package'
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                dir('java-app') {
                    script {
                        sh "docker build -t ${DOCKER_HUB_USER}/${APP_NAME}:latest ."
                        // Optional: sh "docker push ${DOCKER_HUB_USER}/${APP_NAME}:latest"
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Terraform Apply (Deploy Infrastructure)') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }

        stage('Deploy to AWS EC2') {
            steps {
                script {
                    def instanceIp = sh(script: "cd terraform && terraform output -raw public_ip", returnStdout: true).trim()
                    echo "Deploying to: ${instanceIp}"
                    // Here you would typically use SSH to run the docker container on the new EC2
                    // sh "ssh -o StrictHostKeyChecking=no ubuntu@${instanceIp} 'docker run -d -p 8080:8080 ${DOCKER_HUB_USER}/${APP_NAME}:latest'"
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
