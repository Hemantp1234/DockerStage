variable "aws_region" {
  type        = string
  default     = "ap-south-1"
  description = "AWS region for deployment"
}

variable "app_name" {
  type        = string
  default     = "dockerstage"
  description = "Application name prefix"
}

variable "key_name" {
  type        = string
  description = "The exact name of the SSH Key Pair created in AWS EC2 Console (without .pem)"
}