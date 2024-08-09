#!/bin/bash

# Define installation paths
INSTALL_DIR=$HOME/bin
mkdir -p $INSTALL_DIR

# Update PATH
export PATH=$INSTALL_DIR:$PATH

# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl $INSTALL_DIR/eksctl
eksctl version

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl $INSTALL_DIR/kubectl
kubectl version --client

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install --bin-dir $INSTALL_DIR --install-dir $INSTALL_DIR/aws-cli --update
aws --version

# Install Terraform
curl -fsSL "https://releases.hashicorp.com/terraform/$(curl -sL https://releases.hashicorp.com/terraform/ | grep 'href="/terraform/[0-9]' | cut -d'/' -f3 | sort -V | tail -n1)/terraform_$(curl -sL https://releases.hashicorp.com/terraform/ | grep 'href="/terraform/[0-9]' | cut -d'/' -f3 | sort -V | tail -n1)_linux_amd64.zip" -o terraform.zip
unzip terraform.zip
mv terraform $INSTALL_DIR/terraform
terraform -version

# Cleanup
rm -f kubectl awscliv2.zip terraform.zip
rm -rf aws

echo "All tools installed successfully!"
