output "eks_cluster_name" {
  value = aws_eks_cluster.my_cluster.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.my_cluster.endpoint
}

output "eks_cluster_ca_certificate" {
  value = aws_eks_cluster.my_cluster.certificate_authority[0].data
}

output "eks_node_group_name" {
  value = aws_eks_node_group.my_node_group.node_group_name
}

