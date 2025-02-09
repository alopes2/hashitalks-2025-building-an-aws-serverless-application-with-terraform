data "aws_iam_policy_document" "get_movie_item" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:GetItem",
    ]

    resources = [
      aws_dynamodb_table.movies.arn
    ]
  }
}

data "aws_iam_policy_document" "create_movie_item" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:PutItem",
    ]

    resources = [
      aws_dynamodb_table.movies.arn
    ]
  }
}

data "aws_iam_policy_document" "publish_to_movies_updates_sns_topic" {
  statement {
    effect = "Allow"

    actions = [
      "sns:Publish",
    ]

    resources = [
      aws_sns_topic.movie_updates.arn
    ]
  }
}

data "aws_iam_policy_document" "pull_message_from_sqs" {
  statement {
    effect = "Allow"

    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
    ]

    resources = [
      aws_sqs_queue.movie_updates_queue.arn
    ]
  }
}

data "aws_iam_policy_document" "email_notification" {
  statement {
    effect = "Allow"

    actions = [
      "ses:SendEmail",
    ]

    resources = [
      aws_sesv2_email_identity.email_identity.arn,
      aws_sesv2_configuration_set.configuration_set.arn,
    ]
  }
}
