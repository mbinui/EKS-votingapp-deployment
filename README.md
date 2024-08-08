# EKS Deployment

This repository contains files for deploying a voting application and a MySQL database to an Amazon EKS cluster using Jenkins.

## Prerequisites

- AWS account with necessary IAM roles and permissions.
- DockerHub account (with images for MySQL and the voting application).
- Jenkins instance with the AWS Credentials Plugin installed.
- Kubernetes cluster (EKS) with kubectl and eksctl configured.

## Setup

### Clone the Repository

```sh
git clone https://github.com/<your-username>/EKS-deployment.git
cd EKS-deployment


Configure Jenkins and Run the Pipeline
Add AWS Credentials in Jenkins:

Add your AWS credentials in Jenkins (aws-credentials).
Update the Jenkinsfile with your DockerHub credentials and image names.
Create a secret in your Kubernetes cluster for DockerHub (if using private repositories)

Go to Jenkins Dashboard -> Manage Jenkins -> Manage Credentials.
Add a new credential of type "AWS Credentials" and name it aws-credentials.
Create a Jenkins Pipeline Job:

Go to Jenkins Dashboard -> New Item -> Pipeline.
Name the job (e.g., EKS-deployment-pipeline).
In the "Pipeline" section, select "Pipeline script from SCM".
Set "SCM" to "Git".
Enter your repository URL (e.g., https://github.com/<your-username>/EKS-deployment.git).
Click "Save".
Run the Pipeline:



Step 1: Install the AWS Credentials Plugin
Go to Jenkins Dashboard.
Click on "Manage Jenkins".
Click on "Manage Plugins".
Go to the "Available" tab.
Search for "AWS Credentials Plugin".
Install the plugin and restart Jenkins if required.

Step 2: Add AWS Credentials to Jenkins
Go to Jenkins Dashboard.
Click on "Manage Jenkins".
Click on "Manage Credentials".
Select the appropriate domain (e.g., "Global credentials (unrestricted)").
Click on "Add Credentials".
Choose "AWS Credentials" as the kind.
Enter the AWS Access Key ID and Secret Access Key
Give the credentials an ID (e.g., aws-credentials)

Update your Jenkinsfile to use the AWS credentials and configure the AWS CLI


Step 3: Add DockerHub Credentials to Jenkins
If your DockerHub images are private, you'll need to add DockerHub credentials to Jenkins as well.
Go to Jenkins Dashboard.
Click on "Manage Jenkins".
Click on "Manage Credentials".
Select the appropriate domain (e.g., "Global credentials (unrestricted)").
Click on "Add Credentials".
Choose "Username with password" as the kind.
Enter your DockerHub username and password.
Give the credentials an ID (e.g., dockerhub-credentials)

Step 4: Create DockerHub Secret in Kubernetes
Ensure that your Jenkinsfile includes the step to create a secret in your Kubernetes cluster for DockerHub:
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


