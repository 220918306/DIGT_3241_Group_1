variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Must be dev, staging, or prod."
  }
}

variable "repository_prefix" {
  description = "Prefix for repository names."
  type        = string
  default     = "spring-petclinic"
}

variable "image_tag_mutability" {
  description = "MUTABLE or IMMUTABLE."
  type        = string
  default     = "MUTABLE"
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Must be MUTABLE or IMMUTABLE."
  }
}

variable "encryption_type" {
  description = "AES256 or KMS."
  type        = string
  default     = "AES256"
  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "Must be AES256 or KMS."
  }
}

variable "kms_key_arn" {
  description = "KMS key ARN if using KMS encryption."
  type        = string
  default     = null
}

variable "max_image_count" {
  description = "Max images to keep per repo."
  type        = number
  default     = 10
}
#Added this
variable "image_tag" {
  description = "Docker image tag"
  type        = string
}