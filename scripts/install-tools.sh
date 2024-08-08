#!/bin/bash

# Install eksctl
 curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/0.149.0/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
 sudo mv /tmp/eksctl /usr/local/bin

# Install kubectl
 curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
 sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install aws-cli
 curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
 unzip awscliv2.zip
 sudo ./aws/install

# Install helm
 curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

