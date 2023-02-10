data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


#Create SNS, add an email and subscription, and create an SNS policy that allows the lambda to publish.
resource "aws_sns_topic" "periodic_care_package_topic-dev" {
  name = format("periodic_care_package_topic-%s", var.env)
  tags = var.tags
}

resource "aws_sns_topic_subscription" "periodic_care_package_subscriptions-dev" {
  topic_arn = aws_sns_topic.periodic_care_package_topic-dev.arn
  protocol  = "email"
  endpoint  = "alvinlee4197@gmail.com"
}

resource "aws_sns_topic_policy" "period_care_package_sns_policy-dev" {
  arn    = aws_sns_topic.periodic_care_package_topic-dev.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    actions = [
      "SNS:Publish",
    ]

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.periodic_care_package_function_role-dev.arn]
    }

    resources = [
      aws_sns_topic.periodic_care_package_topic-dev.arn,
    ]
  }
}

#Create event to invoke lambda for cron job
resource "aws_cloudwatch_event_rule" "periodic_care_package_schedule" {
  name                = "periodic_care_package_schedule"
  description         = "Schedule for Lambda Function"
  schedule_expression = var.schedule
}

resource "aws_cloudwatch_event_target" "schedule_lambda_target" {
  rule      = aws_cloudwatch_event_rule.periodic_care_package_schedule.name
  target_id = "periodic_lambda"
  arn       = aws_lambda_function.periodic_care_package_lambda.arn
}


resource "aws_lambda_permission" "allow_events_bridge_to_run_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.periodic_care_package_lambda.function_name
  principal     = "events.amazonaws.com"
}

#Create the lambda, create lambda role, add permissions.
data "aws_iam_policy_document" "AWSLambdaTrustPolicy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "periodic_care_package_function_role-dev" {
  name               = format("%s_iam-%s", var.lambda_name, var.env)
  assume_role_policy = data.aws_iam_policy_document.AWSLambdaTrustPolicy.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.periodic_care_package_function_role-dev.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "sns_publish" {
  role       = aws_iam_role.periodic_care_package_function_role-dev.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSIoTDeviceDefenderPublishFindingsToSNSMitigationAction"
}

resource "aws_iam_role_policy_attachment" "xray" {
  role       = aws_iam_role.periodic_care_package_function_role-dev.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.lambda_name}"
  retention_in_days = 1

  tags = var.tags
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../../."
  output_path = "../../periodic-care-package.zip"
  excludes    = ["terraform", "node_modules", "dist", "periodic-care-package.zip", "periodic-care-package-layer.zip"]
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename            = "../../periodic-care-package-layer.zip"
  layer_name          = "periodic-care-package-layer"
  compatible_runtimes = ["nodejs16.x"]
}

resource "aws_lambda_function" "periodic_care_package_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  layers           = [aws_lambda_layer_version.lambda_layer.arn]
  function_name    = format("%s-%s", var.lambda_name, var.env)
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role             = aws_iam_role.periodic_care_package_function_role-dev.arn

  runtime     = "nodejs16.x"
  timeout     = 30
  memory_size = 256
  tags        = var.tags

  environment {
    variables = {
      SNS_ARN = aws_sns_topic.periodic_care_package_topic-dev.arn
    }
  }

}

