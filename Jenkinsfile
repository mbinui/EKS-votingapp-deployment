pipeline {
    agent any  

    parameters {
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Choose whether to apply or destroy the infrastructure')
    }

    environment {
        AWS_REGION = 'us-east-2'
        EKS_CLUSTER_NAME = 'my-voting-app-cluster'
        NAMESPACE = 'voting-app'
        MYSQL_IMAGE = 'mbinui/mysql:latest'
        VOTING_APP_IMAGE = 'mbinui/votingapp:v1'
        MYSQL_DATABASE = 'springboot'
        MYSQL_ROOT_USER = 'root'
        MYSQL_ROOT_PASSWORD = 'rootpassword'
    }

    stages {
        stage('Configure AWS CLI') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    sh '''
                    aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                    aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                    aws configure set default.region $AWS_REGION
                    '''
                }
            }
        }

        stage('Manage EKS Cluster') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                        if (params.ACTION == 'apply') {
                            sh '''
                            cd terraform-eks
                            terraform init
                            terraform apply -auto-approve -var="aws_region=${AWS_REGION}" -var="cluster_name=${EKS_CLUSTER_NAME}"
                            '''
                            sh '''
                            aws eks update-kubeconfig --region $AWS_REGION --name $EKS_CLUSTER_NAME
                            '''
                        } else if (params.ACTION == 'destroy') {
                            sh '''
                            cd terraform-eks
                            terraform destroy -auto-approve -var="aws_region=${AWS_REGION}" -var="cluster_name=${EKS_CLUSTER_NAME}"
                            '''
                        }
                    }
                }
            }
        }

        stage('Create Namespace') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                sh '''
                kubectl create namespace $NAMESPACE || true
                '''
            }
        }

        stage('Create DockerHub Secret') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'DOCKERHUB_PASSWORD', usernameVariable: 'DOCKERHUB_USERNAME')]) {
                    sh '''
                    kubectl create secret docker-registry dockerhub-secret \
                    --docker-server=https://index.docker.io/v1/ \
                    --docker-username=${DOCKERHUB_USERNAME} \
                    --docker-password=${DOCKERHUB_PASSWORD} \
                    --namespace=${NAMESPACE} || true
                    '''
                }
            }
        }

        stage('Create MySQL Secret') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                sh '''
                kubectl create secret generic mysql-root-password \
                --from-literal=username=${MYSQL_ROOT_USER} \
                --from-literal=password=${MYSQL_ROOT_PASSWORD} \
                --namespace=${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
                '''
            }
        }

        stage('Deploy MySQL') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                sh '''
                //kubectl apply -f k8s/mysql-pv.yml
                sed "s/\\${NAMESPACE}/${NAMESPACE}/g" k8s/mysql-pv-claim.yml | kubectl apply -f -
                sed "s/\\${NAMESPACE}/${NAMESPACE}/g" k8s/mysql-deployment.yml | kubectl apply -f -
                sed "s/\\${NAMESPACE}/${NAMESPACE}/g" k8s/mysql-service.yml | kubectl apply -f -
                '''
            }
        }

        stage('Initialize MySQL Database') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                sh '''
                kubectl exec -n ${NAMESPACE} $(kubectl get pod -n ${NAMESPACE} -l app=mysql -o jsonpath="{.items[0].metadata.name}") -- \
                mysql -u${MYSQL_ROOT_USER} -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
                '''
            }
        }

        stage('Deploy Voting Application') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                sh '''
                sed "s/\\${NAMESPACE}/${NAMESPACE}/g" k8s/voting-app-deployment.yml | kubectl apply -f -
                sed "s/\\${NAMESPACE}/${NAMESPACE}/g" k8s/voting-app-service.yml | kubectl apply -f -
                '''
            }
        }

        stage('Verify Deployment') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                sh '''
                kubectl get deployments -n ${NAMESPACE}
                kubectl get pods -n ${NAMESPACE}
                kubectl get svc -n ${NAMESPACE}
                '''
            }
        }

        stage('Get Application URL') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    def svc = sh(script: "kubectl get svc voting-app -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'", returnStdout: true).trim()
                    echo "Application is accessible at: http://$svc"
                }
            }
        }
    }
}












// pipeline {
//     agent any  

//     parameters {
//         choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Choose whether to apply or destroy the infrastructure')
//     }

//     environment {
//         AWS_REGION = 'us-east-2'
//         EKS_CLUSTER_NAME = 'my-voting-app-cluster'
//         NAMESPACE = 'voting-app'
//         MYSQL_IMAGE = 'mbinui/mysql:latest'
//         VOTING_APP_IMAGE = 'mbinui/votingapp:v1'
//     }

//     // stages {
//     //     stage('Set Script Permissions') {
//     //         steps {
//     //             sh 'chmod +x scripts/install-tools.sh'
//     //         }
//     //     }

//     //     stage('Install Tools') {
//     //         steps {
//     //             sh 'scripts/install-tools.sh'
//     //         }
//     //     }

//         stage('Configure AWS CLI') {
//             steps {
//                 withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
//                     sh '''
//                     aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
//                     aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
//                     aws configure set default.region $AWS_REGION
//                     '''
//                 }
//             }
//         }

//         stage('Manage EKS Cluster') {
//             steps {
//                 script {
//                     withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
//                         if (params.ACTION == 'apply') {
//                             sh '''
//                             cd terraform-eks
//                             terraform init
//                             terraform apply -auto-approve -var="aws_region=${AWS_REGION}" -var="cluster_name=${EKS_CLUSTER_NAME}"
//                             '''
//                             sh '''
//                             aws eks update-kubeconfig --region $AWS_REGION --name $EKS_CLUSTER_NAME
//                             //kubectl config get-contexts
//                             //kubectl config use-context arn:aws:eks:$AWS_REGION:032795972194:cluster/$EKS_CLUSTER_NAME
//                             '''
//                         } else if (params.ACTION == 'destroy') {
//                             sh '''
//                             cd terraform-eks
//                             terraform destroy -auto-approve -var="aws_region=${AWS_REGION}" -var="cluster_name=${EKS_CLUSTER_NAME}"
//                             '''
//                         }
//                     }
//                 }
//             }
//         }
//         stage('Create Namespace') {
//             when {
//                 expression { params.ACTION == 'apply' }
//             }
//             steps {
//                 sh '''
//                 kubectl create namespace $NAMESPACE || true
//                 '''
//             }
//         }

//         stage('Create DockerHub Secret') {
//             when {
//                 expression { params.ACTION == 'apply' }
//             }
//             steps {
//                 withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'DOCKERHUB_PASSWORD', usernameVariable: 'DOCKERHUB_USERNAME')]) {
//                     sh '''
//                     kubectl create secret docker-registry dockerhub-secret \
//                     --docker-server=https://index.docker.io/v1/ \
//                     --docker-username=${DOCKERHUB_USERNAME} \
//                     --docker-password=${DOCKERHUB_PASSWORD} \
//                     --namespace=${NAMESPACE} || true
//                     '''
//                 }
//             }
//         }

//         stage('Create MySQL Secret') {
//             when {
//                 expression { params.ACTION == 'apply' }
//             }
//             steps {
//                 withCredentials([string(credentialsId: 'mysql-root-password', variable: 'MYSQL_ROOT_PASSWORD')]) {
//                     sh '''
//                     kubectl create secret generic mysql-root-password \
//                     --from-literal=password=${MYSQL_ROOT_PASSWORD} \
//                     --namespace=${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
//                     '''
//                 }
//             }
//         }

//         stage('Deploy MySQL') {
//             when {
//                 expression { params.ACTION == 'apply' }
//             }
//             steps {
//                 sh '''
//                 kubectl apply -f k8s/mysql-pv.yml
//                 sed "s/\\${NAMESPACE}/${NAMESPACE}/g" k8s/mysql-pv-claim.yml | kubectl apply -f -
//                 sed "s/\\${NAMESPACE}/${NAMESPACE}/g" k8s/mysql-deployment.yml | kubectl apply -f -
//                 sed "s/\\${NAMESPACE}/${NAMESPACE}/g" k8s/mysql-service.yml | kubectl apply -f -
//                 '''
//             }
//         }

//         stage('Deploy Voting Application') {
//             when {
//                 expression { params.ACTION == 'apply' }
//             }
//             steps {
//                 sh '''
//                 sed "s/\\${NAMESPACE}/${NAMESPACE}/g" k8s/voting-app-deployment.yml | kubectl apply -f -
//                 sed "s/\\${NAMESPACE}/${NAMESPACE}/g" k8s/voting-app-service.yml | kubectl apply -f -
//                 '''
//             }
//         }

//         stage('Verify Deployment') {
//             when {
//                 expression { params.ACTION == 'apply' }
//             }
//             steps {
//                 sh '''
//                 kubectl get deployments -n ${NAMESPACE}
//                 kubectl get pods -n ${NAMESPACE}
//                 kubectl get svc -n ${NAMESPACE}
//                 '''
//             }
//         }

//         stage('Get Application URL') {
//             when {
//                 expression { params.ACTION == 'apply' }
//             }
//             steps {
//                 script {
//                     def svc = sh(script: "kubectl get svc voting-app -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'", returnStdout: true).trim()
//                     echo "Application is accessible at: http://$svc"
//                 }
//             }
//         }
//     }
// }
