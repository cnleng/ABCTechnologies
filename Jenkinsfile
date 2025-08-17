pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPO = 'your-ecr-repo-name'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        IMAGE_NAME = "${ECR_REPO}:${IMAGE_TAG}"
        AWS_ACCOUNT_ID = '123456789012'
        ECR_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/cnleng/ABCTechnologies.git'
            }
        }

        stage('Compile') {
            steps {
                sh './mvnw clean compile' // Or './gradlew build' if using Gradle
            }
        }

        stage('Tests') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh './mvnw test' // Or './gradlew test'
                    }
                }
                stage('Integration Tests') {
                    steps {
                        sh './mvnw verify -Pintegration-test' // Adjust as needed
                    }
                }
            }
        }

        stage('Build') {
            steps {
                sh './mvnw package -DskipTests' // Or './gradlew build -x test'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME} ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    sh """
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URI}
                        docker tag ${IMAGE_NAME} ${ECR_URI}:${IMAGE_TAG}
                        docker push ${ECR_URI}:${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Deploy to AWS Kubernetes') {
            steps {
                script {
                    sh """
                        kubectl set image deployment/your-deployment-name your-container-name=${ECR_URI}:${IMAGE_TAG} --namespace your-namespace
                    """
                }
            }
        }
    }

    post {
        success {
            echo '✅ Deployment successful!'
        }
        failure {
            echo '❌ Deployment failed!'
        }
    }
}
