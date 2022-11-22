variable "ami-id" {
  description = "AMI ID of ubuntu 18.04LTS eu-west-2"
  default     = "ami-060c0d1361bbd1bd7"
}

variable "instance-type" {
  description = "Free tier EC2 Instance type"
  default     = "t3.medium"
}

variable "pem-key" {
  description = "Associated Key to SSH into the EC2 Instance"
  default     = "IaC-key"
}

variable "db-user" {
  description = "Username for Database"
  default     = "admin"
}

variable "db-password" {
  description = "MySQL Database Password"
  default     = "Password!1"
}

variable "vm_root_volume_size" {
  description = "Root Volume Size"
  default = "30"
}

variable "vm_root_volume_type" {
  description = "Root volume type"
  default = "gp2"
}

variable "vm_data_volume_size" {
  description = "data volume Size"
  default = "10"
}

variable "vm_data_volume_type" {
  description = "data volume type"
  default = "gp2"
}