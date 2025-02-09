# The email here will receive a verification email
# To set it as verified in SES
resource "aws_sesv2_email_identity" "email_identity" {
  email_identity         = var.email_identity
  configuration_set_name = aws_sesv2_configuration_set.configuration_set.configuration_set_name
}

# Rules to monitor your SES email sending activity, you can create configuration sets and output them in Terraform.
# Event destinations
# IP pool managemen
resource "aws_sesv2_configuration_set" "configuration_set" {
  configuration_set_name = "movies-configuration-set"
}
