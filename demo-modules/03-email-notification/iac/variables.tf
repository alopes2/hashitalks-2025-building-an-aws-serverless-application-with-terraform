variable "region" {
  description = "Default region of your resources"
  type        = string
  default     = "eu-central-1"
}

variable "account_id" {
  description = "The ID of the default AWS account"
  type        = string
}

variable "email_identity" {
  description = "The email to be configured in configured in SES"
  type        = string
}

variable "destination_email" {
  description = "The destination email for the email notification Lambda function"
  type        = string
}
