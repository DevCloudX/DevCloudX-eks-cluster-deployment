output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.devopsola.name
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS Kubernetes API"
  value       = aws_eks_cluster.devopsola.endpoint
}

output "cluster_ca_certificate" {
  description = "The base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.devopsola.certificate_authority[0].data
}

output "vpc_id" {
  description = "The ID of the VPC created for the EKS cluster"
  value       = aws_vpc.devopsola_vpc.id
}

output "subnet_ids" {
  description = "The IDs of the subnets created for the EKS cluster"
  value       = aws_subnet.devopsola_subnet[*].id
}

output "node_group_role_arn" {
  description = "The ARN of the IAM role used by the EKS worker node group"
  value       = aws_iam_role.devopsola_node_group_role.arn
}
