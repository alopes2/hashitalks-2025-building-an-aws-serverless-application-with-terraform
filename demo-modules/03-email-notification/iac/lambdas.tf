module "get_movie_lambda" {
  source   = "./modules/lambda"
  name     = "get-movie"
  policies = [data.aws_iam_policy_document.get_movie_item.json]
  environment_variables = {
    TABLE_NAME = aws_dynamodb_table.movies.name
  }
}

module "create_movie_lambda" {
  source = "./modules/lambda"
  name   = "create-movie"
  policies = [
    data.aws_iam_policy_document.create_movie_item.json,
    data.aws_iam_policy_document.publish_to_movies_updates_sns_topic.json
  ]

  environment_variables = {
    TABLE_NAME    = aws_dynamodb_table.movies.name
    SNS_TOPIC_ARN = "arn:aws:sns:${var.region}:${var.account_id}:${local.movies_update_topic_name}"
  }
}

module "email_notification_lambda" {
  source = "./modules/lambda"
  name   = "email-movie-notification"
  policies = [
    data.aws_iam_policy_document.pull_message_from_sqs.json,
    data.aws_iam_policy_document.email_notification.json
  ]
  environment_variables = {
    SOURCE_EMAIL      = "${var.email_identity}"
    DESTINATION_EMAIL = "${var.destination_email}"
  }
}

resource "aws_lambda_event_source_mapping" "email_notification_trigger" {
  event_source_arn = aws_sqs_queue.movie_updates_queue.arn
  function_name    = module.email_notification_lambda.arn
  enabled          = true
}
