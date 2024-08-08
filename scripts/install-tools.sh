# #!/bin/bash

# # Install eksctl
#  curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/0.149.0/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
#  sudo mv /tmp/eksctl /usr/local/bin

# # Install kubectl
#  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
#  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# # Install aws-cli
#  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#  unzip awscliv2.zip
#  sudo ./aws/install

# # Install helm
#  curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

#!/bin/bash

set -e

# Install eksctl
echo "Installing eksctl..."
if ! command -v eksctl &> /dev/null; then
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/0.149.0/eksctl_$(uname -s)_amd64.tar.gz" -o /tmp/eksctl.tar.gz
    tar xz -C /tmp -f /tmp/eksctl.tar.gz
    sudo mv /tmp/eksctl /usr/local/bin
    rm /tmp/eksctl.tar.gz
    echo "eksctl installed successfully."
else
    echo "eksctl already installed."
fi

# Install kubectl
echo "Installing kubectl..."
if ! command -v kubectl &> /dev/null; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o /tmp/kubectl
    sudo install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl
    rm /tmp/kubectl
    echo "kubectl installed successfully."
else
    echo "kubectl already installed."
fi

# Install AWS CLI
echo "Installing AWS CLI..."
if ! command -v aws &> /dev/null; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
    unzip /tmp/awscliv2.zip -d /tmp
    sudo /tmp/aws/install
    rm -rf /tmp/awscliv2.zip /tmp/aws
    echo "AWS CLI installed successfully."
else
    echo "AWS CLI already installed."
fi

# Install Helm
echo "Installing Helm..."
if ! command -v helm &> /dev/null; then
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
    echo "Helm installed successfully."
else
    echo "Helm already installed."
fi

# Install Terraform
echo "Installing Terraform..."
if ! command -v terraform &> /dev/null; then
    curl -LO "https://releases.hashicorp.com/terraform/1.5.3/terraform_1.5.3_linux_amd64.zip" -o /tmp/terraform.zip
    unzip /tmp/terraform.zip -d /tmp
    sudo mv /tmp/terraform /usr/local/bin/
    rm /tmp/terraform.zip
    echo "Terraform installed successfully."
else
    echo "Terraform already installed."
fi

# Install Docker
echo "Installing Docker..."
if ! command -v docker &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    echo \
      "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    sudo usermod -aG docker $USER
    echo "Docker installed successfully."
else
    echo "Docker already installed."
fi

echo "All tools installed successfully."
