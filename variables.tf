
variable "region" {
  type        = string
  description = "Geographic location of the resource (e.g. us-south, us-east)"
}

variable "guid" {
  type        = string
  description = "The guid of the existing Sysdig instance"
}

variable "access_key" {
  type        = string
  description = "The access key of the existing Sysdig instance"
}

variable "namespace" {
  type        = string
  description = "The namespace where the agent should be deployed"
  default     = "ibm-observe"
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster into which the sysdig instance should be bound"
  default     = ""
}

variable "cluster_id" {
  type        = string
  description = "The id of the cluster into which the sysdig instance should be bound"
  default     = ""
}

variable "cluster_config_file_path" {
  type        = string
  description = "The path to the config file for the cluster"
  default     = ""
}

variable "sync" {
  type        = string
  description = "Semaphore value to sync up modules"
  default     = ""
}

variable "tools_namespace" {
  type        = string
  description = "The namespace where the tools have been deployed (where the configmap should be created)"
  default     = "default"
}

variable "private_endpoint" {
  type        = string
  description = "Flag indicating that the agent should be created with private endpoints"
  default     = "true"
}
