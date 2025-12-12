output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_arn" {
  value = module.eks.cluster_arn
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}   

output "frontend_repository_url" {
  value = aws_ecr_repository.frontend_repository.repository_url
}

output "backend_repository_url" {
  value = aws_ecr_repository.backend_repository.repository_url
}

output "existing_vpc_id" {
  value = data.aws_vpc.existing.id
}
