# Specify the required Terraform version
terraform {
  required_version = ">= 1.3.0"  # Update to match your Terraform version
}

# Specify the required providers
provider "aws" {
  region = var.aws_region
}

# Optionally, specify the required version for the AWS provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"  # Update to the version compatible with your configuration
    }
  }
}

# If you use other providers, you can add them here
# For example, if using the Kubernetes provider:
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Example if you use the Helm provider (if you plan to use Helm charts):
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
