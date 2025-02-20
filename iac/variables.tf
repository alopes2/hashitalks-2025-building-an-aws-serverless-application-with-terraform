variable "region" {
  description = "Default region of your resources"
  type        = string
  default     = "eu-central-1"
}

variable "account_id" {
  description = "The ID of the default AWS account"
  type        = string
}
