pipeline {
    agent any

    environment {
        AWS_REGION = 'us-west-2'
        EKS_CLUSTER_NAME = 'my-voting-app-cluster'
        NAMESPACE = 'voting-app'
        MYSQL_ROOT_PASSWORD = 'mysecurepassword'  // Use a secure password
        MYSQL_IMAGE = '<your-dockerhub-username>/mysql:latest'
        VOTING_APP_IMAGE = '<your-dockerhub-username>/voting-app:latest'
    }

    stages {
        stage('Install Tools') {
            steps {
                sh 'scripts/install-tools.sh'
            }
        }

        stage('Configure AWS CLI') {
            steps {
                withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                    sh '''
                    aws eks update-kubeconfig --region $AWS_REGION --name $EKS_CLUSTER_NAME
                    '''
                }
            }
        }

        stage('Create Namespace') {
            steps {
                sh '''
                kubectl create namespace $NAMESPACE || true
                '''
            }
        }

        stage('Deploy MySQL') {
            steps {
                sh '''
                kubectl apply -f k8s/mysql-pv.yml
                kubectl apply -f k8s/mysql-pv-claim.yml
                kubectl apply -f k8s/mysql-deployment.yml
                kubectl apply -f k8s/mysql-service.yml
                '''
            }
        }

        stage('Deploy Voting Application') {
            steps {
                sh '''
                kubectl apply -f k8s/voting-app-deployment.yml
                kubectl apply -f k8s/voting-app-service.yml
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                kubectl get deployments -n ${NAMESPACE}
                kubectl get pods -n ${NAMESPACE}
                kubectl get svc -n ${NAMESPACE}
                '''
            }
        }

        stage('Get Application URL') {
            steps {
                script {
                    def svc = sh(script: "kubectl get svc voting-app -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'", returnStdout: true).trim()
                    echo "Application is accessible at: http://$svc"
                }
            }
        }
    }
}
