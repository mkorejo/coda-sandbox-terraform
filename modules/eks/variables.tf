variable "k8s_version" {
  type = string
  description = "Kubernetes version"
  default = "1.15"
}

variable "prefix" {
  type = string
  description = "Prefix/name for resources"
}

variable "subnet_ids" {
  type = list
  description = "List of subnet IDs for the cluster"
}

variable "tags" {
  type = map
  default = {}
}