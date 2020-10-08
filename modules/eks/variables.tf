variable "aws_account_id" {
  type = string
}

variable "k8s_version" {
  type = string
  description = "Kubernetes version"
  default = "1.17"
}

variable "node_group_instance_types" {
  type = list
  description = "EC2 instance type for the cluster's initial node group"
  default = ["t3.medium"]
}

variable "node_group_labels" {
  type = map
  description = "Labels to apply to nodes in the cluster's initial node group"
  default = {}
}

variable "node_group_name" {
  type = string
  description = "Name of the cluster's initial node group"
  default = "infra"
}

variable "node_group_scale_desired" {
  type = string
  description = "Desired node count for this pool"
  default = "3"
}

variable "node_group_scale_max" {
  type = string
  description = "Maximum node count for this pool"
  default = "5"
}

variable "node_group_scale_min" {
  type = string
  description = "Minimum node count for this pool"
  default = "1"
}

variable "node_group_ssh_key" {
  type = string
  description = "EC2 key pair for remote access to nodes in the cluster's initial node group"
}

variable "prefix" {
  type = string
  description = "Prefix/name for resources"
}

variable "subnet_ids" {
  type = list(string)
  description = "List of subnet IDs for the cluster"
}

variable "tags" {
  type = map
  default = {}
}

variable "vpc_id" {
  type = string
}