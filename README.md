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

