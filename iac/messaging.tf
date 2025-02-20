locals {
  movies_update_topic_name = "movie-updates-topic"
}

resource "aws_sns_topic" "movie_updates" {
  name = local.movies_update_topic_name
}

resource "aws_sqs_queue" "movie_updates_queue" {
  name   = "movie-updates-queue"
  policy = data.aws_iam_policy_document.sqs-queue-policy.json
}

resource "aws_sns_topic_subscription" "movie_updates_sqs_target" {
  topic_arn            = aws_sns_topic.movie_updates.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.movie_updates_queue.arn
  raw_message_delivery = true
}

data "aws_iam_policy_document" "sqs-queue-policy" {
  policy_id = "arn:aws:sqs:${var.region}:${var.account_id}:movie-updates-queue/SQSDefaultPolicy"

  statement {
    sid    = "movie_updates-sns-topic"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    actions = [
      "SQS:SendMessage",
    ]

    resources = [
      "arn:aws:sqs:${var.region}:${var.account_id}:movie-updates-queue",
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"

      values = [
        aws_sns_topic.movie_updates.arn,
      ]
    }
  }
}
