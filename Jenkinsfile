pipeline {
    agent any

    // 1. Loading the tools you named in 'Manage Jenkins' -> 'Tools'
    tools {
        maven 'maven'        // Must match the name in Jenkins Global Tool Configuration
        terraform 'terraform' // Must match the name in Jenkins Global Tool Configuration
    }

    environment {
        // ID of the credentials you created in Jenkins
        AWS_ID = 'aws-creds'
        DOCKER_HUB_USER = "pawarpr"
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
                        // Uses the host's docker engine via the mounted socket
                        sh "docker build -t ${DOCKER_HUB_USER}/${APP_NAME}:latest ."
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                // 2. Wrap in withAWS so Terraform can authenticate
                withAWS(credentials: "${AWS_ID}", region: 'us-east-1') {
                    dir('terraform') {
                        sh 'terraform init'
                        sh 'terraform plan -out=tfplan'
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withAWS(credentials: "${AWS_ID}", region: 'us-east-1') {
                    dir('terraform') {
                        sh 'terraform apply -auto-approve tfplan'
                    }
                }
            }
        }

        stage('Deploy to AWS EC2') {
            steps {
                script {
                    // Capture the IP from Terraform output
                    def instanceIp = sh(script: "cd terraform && terraform output -raw instance_public_ip", returnStdout: true).trim()
                    echo "Infrastructure is live at: ${instanceIp}"
                    
                    // Note: To run the container on the EC2, you'll need SSH keys configured
                    // echo "Future step: ssh ubuntu@${instanceIp} 'docker run...'"
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
