pipeline {
    agent any
    environment {
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        DOCKERHUB_REPO = 'cnleng/abctechnologies-war-app'
        IMAGE_NAME = "${DOCKERHUB_REPO}:${IMAGE_TAG}"
    }
    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "maven3"
    }

    stages {
        stage('Checkout (Git)') {
            steps {
                // Get some code from a GitHub repository
                git branch: 'main', url: 'https://github.com/cnleng/ABCTechnologies.git'
            }
        }

        stage('Compile (Maven)') {
            agent { label 'worker1' } 
            steps {
                // Run Maven on a Unix agent.
                git branch: 'main', url: 'https://github.com/cnleng/ABCTechnologies.git'
                sh "mvn -DskipTests clean compile"
            }
        }
        
        stage('Tests') {
            steps {
                // Run Maven on a Unix agent.
                sh "mvn test"
            }
        }
        
        stage('Package (Maven)') {
            steps {
                // Run Maven on a Unix agent.
                sh "mvn clean package -DskipTests"
            }
        }
        
       stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKERHUB_REPO}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKERHUB_USER',
                        passwordVariable: 'DOCKERHUB_PASS'
                    )]) {
                        sh """
                            echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin
                            docker push ${DOCKERHUB_REPO}:${IMAGE_TAG}
                            docker tag ${DOCKERHUB_REPO}:${IMAGE_TAG} ${DOCKERHUB_REPO}:latest
                            docker push ${DOCKERHUB_REPO}:latest
                        """
                    }
                }
            }
        }
        
       stage('Deploy to Kubernetes Deployment') {
            steps {
                script {
                    withCredentials([file(credentialsId: 'k3s-kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                        withEnv(["KUBECONFIG=$KUBECONFIG_FILE"]) {
                            sh """
                                kubectl apply -f k8s/deployment.yaml
                            """
                        }
                    }
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

