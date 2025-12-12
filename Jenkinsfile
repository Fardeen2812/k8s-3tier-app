// jenkins declarative pipeline for eks deployment
pipeline {
    agent any

    // Define environment variables
    environment {
        AWS_REGION = 'us-east-1'
        CLUSTER_NAME = 'eks-cluster-K8s-3Tier-App'
        APP_NAME = 'my-3tier-app'
        AWS_ACCOUNT_ID = '663789292765'
        // Dynamic tag for image versioning
        IMAGE_TAG = "jenkins-${BUILD_NUMBER}"

        // Credential IDs for ECR/EKS access (assumed to be set up in Jenkins)
        AWS_CREDENTIALS_ID = 'aws-jenkins-creds'

        // ECR Respository URL
        BACKEND_REPO_URL = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/backend-repository-k8s-3tier-app"
        FRONTEND_REPO_URL = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/frontend-repository-k8s-3tier-app"
    }
    stages {
        stage('Checkout Code') {
            steps {
                // Checkout the code from the repository
                checkout scm
            }
        }

        stage ('Tools setup and eks config') {
            // Step 1: Configure kubectl access to EKS cluster
            // Assuming AWS CLI are already installed on the Jenkins agent
            steps {
                withAWS(credentials: "${AWS_CREDENTIALS_ID}", region: "${AWS_REGION}") {
                    sh '''
                        aws eks --region ${AWS_REGION} update-kubeconfig --name ${CLUSTER_NAME}
                        kubectl get nodes // test connectivity
                    '''
                }
        }
        }
        stage('Build and Push Backend Images') {
            steps {
                {
                // Step 2: Login to ECR
                // We use the AWS CLI to get a temporary login password for Docker
                sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

                // Step 3: Build and Push the Backend Image
                // We use 'docker buildx' to force the linux/amd64 architecture 
                // to avoid the 'exec format error' on non-amd64 Jenkins agents 
                sh "docker buildx build --platform linux/amd64 --push -t ${BACKEND_REPO_URL}:${IMAGE_TAG} ./backend"
               }
            }
        }
        stage('Build and Push Frontend Images') {
            steps {
                {
                // Step 4: Build and Push the Frontend Image
                sh "docker buildx build --platform linux/amd64 --push -t ${FRONTEND_REPO_URL}:${IMAGE_TAG} ./frontend"
            }
        }
        }
        stage('Deploy to EKS') {
            steps {
                // Step 5: Deploy the application to EKS using kubectl
                sh '''
                    kubectl set image deployment/backend-deployment backend-container=${BACKEND_REPO_URL}:${IMAGE_TAG} --record
                    kubectl set image deployment/frontend-deployment frontend-container=${FRONTEND_REPO_URL}:${IMAGE_TAG} --record
                '''
            }
        }
        stage('Post-Deployment Verification') {
            steps {
                // Step 6: Verify the deployment
                sh '''
                    kubectl rollout status deployment/backend-deployment --timeout=5m
                    kubectl rollout status deployment/frontend-deployment --timeout=5m
                    kubectl get pods
                '''
            }
        }
    }
}

