
variable "name" {
  description = "The name of the Lambda function"
  type        = string
  nullable    = false
}

variable "environment_variables" {
  description = "The environment variables for this lambda"
  type        = map(string)
  default     = {}
}

variable "policies" {
  description = "The policies for this lambda."
  type        = list(string)
  default     = null
}
