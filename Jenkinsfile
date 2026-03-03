pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKERHUB_USERNAME = "dinesh0793"
        IMAGE_NAME = "react-devops-app"
    }

    triggers {
        githubPush()
    }

    stages {
        stage('Checkout') {
            steps {
                echo "📥 Checking out source code from branch: ${env.BRANCH_NAME}"
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🔨 Building Docker image..."
                sh "chmod +x build.sh"
                sh "./build.sh ${env.BUILD_NUMBER}"
            }
        }

        stage('Login to Docker Hub') {
            steps {
                echo "🔐 Logging into Docker Hub..."
                sh "echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin"
            }
        }

        stage('Push to Dev Repo') {
            when {
                branch 'dev'
            }
            steps {
                echo "📤 Pushing to DEV Docker Hub repo..."
                sh """
                    docker tag ${IMAGE_NAME}:${env.BUILD_NUMBER} ${DOCKERHUB_USERNAME}/dev:${env.BUILD_NUMBER}
                    docker tag ${IMAGE_NAME}:${env.BUILD_NUMBER} ${DOCKERHUB_USERNAME}/dev:latest
                    docker push ${DOCKERHUB_USERNAME}/dev:${env.BUILD_NUMBER}
                    docker push ${DOCKERHUB_USERNAME}/dev:latest
                """
                echo "✅ Image pushed to dev repo: ${DOCKERHUB_USERNAME}/dev:${env.BUILD_NUMBER}"
            }
        }

        stage('Push to Prod Repo') {
            when {
                branch 'master'
            }
            steps {
                echo "📤 Pushing to PROD Docker Hub repo (private)..."
                sh """
                    docker tag ${IMAGE_NAME}:${env.BUILD_NUMBER} ${DOCKERHUB_USERNAME}/prod:${env.BUILD_NUMBER}
                    docker tag ${IMAGE_NAME}:${env.BUILD_NUMBER} ${DOCKERHUB_USERNAME}/prod:latest
                    docker push ${DOCKERHUB_USERNAME}/prod:${env.BUILD_NUMBER}
                    docker push ${DOCKERHUB_USERNAME}/prod:latest
                """
                echo "✅ Image pushed to prod repo: ${DOCKERHUB_USERNAME}/prod:${env.BUILD_NUMBER}"
            }
        }

        stage('Deploy to Server') {
            when {
                branch 'master'
            }
            steps {
                echo "🚀 Deploying application to server..."
                sh "chmod +x deploy.sh"
                sh "./deploy.sh ${env.BUILD_NUMBER}"
                echo "✅ Application deployed and running on port 80"
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully for branch: ${env.BRANCH_NAME}"
        }
        failure {
            echo "❌ Pipeline failed for branch: ${env.BRANCH_NAME}"
        }
        always {
            sh "docker logout"
        }
    }
}
