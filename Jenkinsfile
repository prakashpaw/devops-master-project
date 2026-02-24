pipeline {
    agent any

    tools {
        // Keep Maven here because it's managed by Jenkins
        maven 'maven' 
        // We removed 'terraform' from here because it's now a system binary
    }

    environment {
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

        stage('Docker Build') {
            steps {
                dir('java-app') {
                    script {
                        // This uses the /var/run/docker.sock permission we set
                        sh "docker build -t ${DOCKER_HUB_USER}/${APP_NAME}:latest ."
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withAWS(credentials: "${AWS_ID}", region: 'us-east-1') {
                    dir('terraform') {
                        // This will now use /usr/bin/terraform
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
                    def instanceIp = sh(script: "cd terraform && terraform output -raw public_ip", returnStdout: true).trim()
                    echo "SUCCESS: Your infrastructure is live at http://${instanceIp}:8080"
                }
            }
        }
    }

    post {
        always {
            script {
                try {
                    cleanWs()
                } catch (Exception e) {
                    echo "Cleanup skipped: Workspace not found."
                }
            }
        }
    }
}
