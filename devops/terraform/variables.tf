variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Used for tagging resources"
  type        = string
  default     = "deepdive-course"
}

variable "instance_type" {
  description = "EC2 instance type (t3.micro is free-tier eligible)"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH access (leave empty to skip)"
  type        = string
  default     = ""
}

variable "django_secret_key" {
  description = "Django SECRET_KEY for production"
  type        = string
  sensitive   = true
}

variable "ghcr_username" {
  description = "GitHub username used to pull the image from GHCR"
  type        = string
}

variable "ghcr_token" {
  description = "GitHub Personal Access Token with read:packages scope for pulling from GHCR"
  type        = string
  sensitive   = true
}

variable "django_image" {
  description = "Full GHCR image reference to deploy, e.g. ghcr.io/your-username/deepdive_course:latest"
  type        = string
  default     = ""
}

variable "allowed_hosts" {
  description = "List of allowed hostnames for Django ALLOWED_HOSTS"
  type        = list(string)
  default     = ["pgdeepdive.pl"]
}