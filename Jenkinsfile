pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "arghyanil/hello-devops"
        EC2_HOST = "13.203.228.220"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/ArghyanilChowdhury/hello-devops-ci-cd.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                bat 'docker build -t %DOCKER_IMAGE%:latest .'
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    powershell '''
                        $env:DOCKER_PASS | docker login -u $env:DOCKER_USER --password-stdin
                        docker push $env:DOCKER_IMAGE`:latest
                    '''
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'ec2-ssh-key',
                    keyFileVariable: 'SSH_KEY',
                    usernameVariable: 'SSH_USER'
                )]) {
                    powershell '''
                        ssh -i $env:SSH_KEY -o StrictHostKeyChecking=no $env:SSH_USER@$env:EC2_HOST "docker pull $env:DOCKER_IMAGE`:latest && docker stop hello-devops-container || true && docker rm hello-devops-container || true && docker run -d -p 80:80 --name hello-devops-container $env:DOCKER_IMAGE`:latest"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline executed successfully.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}