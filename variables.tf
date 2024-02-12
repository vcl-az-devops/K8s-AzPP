
# Network Variables
variable "vnet_name" {}
variable "vnet_address" {
  type = list
}

variable "subnet_address" {
  type = list
}


variable "tags" {}
variable "k8s_name" {}
variable "vm_size" {}
variable "k8s_rg" {}
variable "client_id" {}
variable "client_secret" {}