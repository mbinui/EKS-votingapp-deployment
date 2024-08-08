pipeline {
    agent any

    environment {
        AWS_REGION = 'us-west-2'
        EKS_CLUSTER_NAME = 'my-voting-app-cluster'
        NAMESPACE = 'voting-app'
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
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    sh '''
                    aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                    aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                    aws configure set default.region $AWS_REGION
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

        stage('Create DockerHub Secret') {
            steps {
                sh '''
                kubectl create secret docker-registry dockerhub-secret \
                --docker-server=https://index.docker.io/v1/ \
                --docker-username=<your-dockerhub-username> \
                --docker-password=<your-dockerhub-password> \
                --docker-email=<your-email> \
                --namespace=${NAMESPACE} || true
                '''
            }
        }

        stage('Deploy MySQL') {
            steps {
                withCredentials([string(credentialsId: 'mysql-root-password', variable: 'MYSQL_ROOT_PASSWORD')]) {
                    sh '''
                    kubectl apply -f k8s/mysql-pv.yml
                    kubectl apply -f k8s/mysql-pv-claim.yml
                    envsubst < k8s/mysql-deployment.yml | kubectl apply -f -
                    kubectl apply -f k8s/mysql-service.yml
                    '''
                }
            }
        }

        stage('Deploy Voting Application') {
            steps {
                withCredentials([string(credentialsId: 'mysql-root-password', variable: 'MYSQL_ROOT_PASSWORD')]) {
                    sh '''
                    envsubst < k8s/voting-app-deployment.yml | kubectl apply -f -
                    kubectl apply -f k8s/voting-app-service.yml
                    '''
                }
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
