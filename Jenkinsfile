pipeline {
    agent any

    tools {
        // This 'maven' name must match exactly what you configured in Manage Jenkins -> Tools
        maven 'maven'
    }

    environment {
        // IDs for your saved Credentials in Jenkins
        AWS_ID = 'aws-creds'
        DOCKER_HUB_CREDS_ID = 'docker-hub-creds' 
        
        // Docker Hub details
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
                    // Compiles Java code and creates the JAR
                    sh 'mvn clean package'
                }
            }
        }

        stage('Docker Build') {
            steps {
                dir('java-app') {
                    script {
                        // Build the image locally on your Ubuntu host
                        sh "docker build -t ${DOCKER_HUB_USER}/${APP_NAME}:latest ."
                    }
                }
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    // This is the missing link! Pushes the image to the cloud
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_HUB_CREDS_ID}", passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                        sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                        sh "docker push ${DOCKER_HUB_USER}/${APP_NAME}:latest"
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
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
                    // Fetch the IP from the Terraform state to show in logs
                    def instanceIp = sh(script: "cd terraform && terraform output -raw instance_public_ip", returnStdout: true).trim()
                    echo "SUCCESS: Your infrastructure is live at http://${instanceIp}:8080"
                }
            }
        }
    }

    post {
        always {
            script {
                try {
                    // Keeps your host storage clean
                    cleanWs()
                } catch (Exception e) {
                    echo "Cleanup skipped: Workspace folder not available."
                }
            }
        }
    }
}
