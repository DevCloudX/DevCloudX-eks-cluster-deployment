variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_azs" {
  description = "List of Availability Zones for subnets"
  type        = list(string)
  default     = ["us-west-1a", "us-west-1b"]
}

variable "vpc_name" {
  description = "Name tag for the VPC and related resources"
  type        = string
  default     = "DevCloudX"
}

variable "route_table_name" {
  description = "Name tag for the route table"
  type        = string
  default     = "DevCloudX"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
