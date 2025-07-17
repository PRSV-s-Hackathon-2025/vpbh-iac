variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "vpbh-bigdata-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "node_groups" {
  description = "EKS node group configuration"
  type = map(object({
    instance_types = list(string)
    subnet_ids     = list(number)
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
  }))
  default = {
    api = {
      instance_types = ["t3.medium"]
      subnet_ids     = [0, 1]
      scaling_config = {
        desired_size = 2
        max_size     = 4
        min_size     = 1
      }
    }
    clickhouse = {
      instance_types = ["r5.xlarge"]
      subnet_ids     = [2, 3]
      scaling_config = {
        desired_size = 1
        max_size     = 3
        min_size     = 1
      }
    }
  }
}

variable "key_name" {
  description = "EC2 Key Pair name for Kafka instances"
  type        = string
  default     = "vpbh-bigdata-key"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "dev"
    Project     = "vpbh-bigdata"
  }
}

