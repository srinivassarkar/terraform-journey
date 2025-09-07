
variable "vpc_parameters" {
  description = "Map for VPC configurations"
  type = map(object({
    cidr_block           = string
    enable_dns_support   = bool
    enable_dns_hostnames = bool
    tags                 = map(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for vpc_name, vpc_config in var.vpc_parameters :
      can(cidrhost(vpc_config.cidr_block, 0)) # Validates CIDR format
    ])
    error_message = "All VPC CIDR blocks must be Valid CIDR notation."
  }
}


variable "subnet_parameters" {
  description = "map of subnet configurations"
  type = map(object({
    vpc_name                = string
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = optional(bool, false)       #optional with default
    subnet_type             = optional(string, "private") #by default private otherwise include public
    tags                    = map(string)

  }))

  default = {}
}

variable "igw_parameters" {
  description = "Map for IGW configurations"

  type = map(object({
    vpc_name = string
    tags     = map(string)
  }))
  default = {}
}


variable "nat_parameters" {
  description = "Map of NAT Gateway configurations"

  type = map(object({
    subnet_name = string
    tags        = map(string)
  }))
  default = {}

}

variable "rt_parameters" {
  description = "Map for route table config with dyanmic routers"

  type = map(object({
    vpc_name = string
    tags     = map(string)
    routes = list(object({
      cidr_block = string
      use_igw    = optional(bool, false)
      use_nat    = optional(bool, false)
      gateway_id = optional(string, null) # IGW/NAT name for lookup 
    }))
  }))
  default = {}

  validation {
    condition = alltrue(flatten([
      for rt_name, rt_config in var.rt_parameters : [
        for route in rt_config.routes :
        (route.use_igw && !route.use_nat) || (!route.use_igw && route.use_nat) || (!route.use_igw && !route.use_nat) # For each route, it verifies that the route either uses IGW (Internet Gateway) or NAT (Network Address Translation), or neither, but not both at the same time.
      ]
    ]))
    error_message = "Each route must use either IGW or NAT, not both."
  }

}


variable "rt_association_parameters" {
  description = "Map of RT associaton config."


  type = map(object({
    subnet_name = string # Links to subnet
    rt_name     = string # Links to route table
  }))


}

#  HELPER VARIABLES for easier module consumption
variable "project_name" {
  description = "Project name for consistent naming"
  type        = string
  default     = "vpc-module"
}

variable "environment" {
  description = "Environment (dev/staging/prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# locals for computed values
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    CreatedAt   = timestamp()
  }
}
