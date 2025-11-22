pipeline {
    agent any
 
    environment {
        PROJECT_ID = "burner-viskonet"
        IMAGE_NAME = "api_cloud"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        GKE_CLUSTER = "cluster-us-central1"
        GKE_ZONE = "us-central1-a"
        REGISTRY = "us-central1-docker.pkg.dev"
        REPO_NAME = "api_cloud"
        SERVICE_ACCOUNT_KEY = credentials('gcp-sa-key')   // Stored in Jenkins Credentials
    }
 
    stages {
        
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/viskonet-rgb/api_cloud.git'
            }
        }
 
        stage('Authenticate to GCP') {
            steps {
                sh """
                echo '${SERVICE_ACCOUNT_KEY}' > key.json
                gcloud auth activate-service-account --key-file=key.json
                gcloud config set project $PROJECT_ID
                gcloud auth configure-docker ${REGISTRY} --quiet
                """
            }
        }
 
        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t ${REGISTRY}/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG} .
                """
            }
        }
 
        stage('Push Docker Image') {
            steps {
                sh "docker push ${REGISTRY}/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }
 
        stage('Connect to GKE') {
            steps {
                sh """
                gcloud container clusters get-credentials ${GKE_CLUSTER} --zone ${GKE_ZONE} --project ${PROJECT_ID}
                """
            }
        }
 
        stage('Deploy to GKE') {
            steps {
                sh """
                kubectl set image deployment/${IMAGE_NAME} ${IMAGE_NAME}=${REGISTRY}/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG} --record -n banking-prod-namespace
                kubectl rollout status deployment/${IMAGE_NAME} -n ns-workaround
                """
            }
        }
         
    post {
        success {
            echo "Deployment successful 🎉"
        }
        failure {
            echo "Deployment failed ❌"
        }
    }
}
