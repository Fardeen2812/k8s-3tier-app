variable "aws_region" {
  description = "The AWS region to deploy the resources to"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "The name of the EKS cluster to deploy the resources to"
  type        = string
  default     = "eks-cluster-K8s-3Tier-App"
}

variable "node_group_name" {
  description = "The name of the EKS node group to deploy the resources to"
  type        = string
  default     = "eks-ng-3tier-app"
}
