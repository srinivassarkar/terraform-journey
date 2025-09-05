variable "aws_region" {
  description = "aws region"
  type        = string
  default     = "us-east-1"

}

variable "vpc_name" {
  description = "name of the vpc"
  type        = string
  default     = "vpc demo"

}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"

}

variable "availablity_zones" {
  description = "az's"
  type        = list(string)
  default     = ["us-east-1a", "us-east-2b"]

}

