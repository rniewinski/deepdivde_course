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

variable "app_git_url" {
  description = "Git repository HTTPS URL (without credentials)"
  type        = string
  default     = "https://github.com/your-user/deepdivde_course.git"
}

variable "git_token" {
  description = "GitHub/GitLab Personal Access Token for private repos (leave empty for public)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "django_secret_key" {
  description = "Django SECRET_KEY for production"
  type        = string
  sensitive   = true
}
