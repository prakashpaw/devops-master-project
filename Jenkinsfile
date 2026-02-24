pipeline {
    agent any

    tools {
        // This 'maven' name must match exactly what you configured in Manage Jenkins -> Tools
        maven 'maven'
    }

    environment {
        // Use the ID you set in Jenkins Credentials
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
                    // Compiles the Java code and creates the JAR file
                    sh 'mvn clean package'
                }
            }
        }

        stage('Docker Build') {
            steps {
                dir('java-app') {
                    script {
                        // Builds the image using the host's Docker engine via the socket mount
                        sh "docker build -t ${DOCKER_HUB_USER}/${APP_NAME}:latest ."
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withAWS(credentials: "${AWS_ID}", region: 'us-east-1') {
                    dir('terraform') {
                        // Using the system-installed terraform binary we added to /usr/bin
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
                    // MATCHED: fetching 'instance_public_ip' to match your main.tf output
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
                    // Cleans the workspace after build to keep your Ubuntu host storage clear
                    cleanWs()
                } catch (Exception e) {
                    echo "Cleanup skipped: Workspace folder not available."
                }
            }
        }
    }
}
