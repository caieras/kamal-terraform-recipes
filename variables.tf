variable "region" {
  type = string
  description = "Resources Region"
  default = "us-east-1"
}

variable "app_tag" {
  description = "App tag name"
  type        = string
  default     = "app-tag"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "staging"
}
