provider "aws" {}

locals {
  name = "kinesis-example"
}

# -----------------------------------------------------------------------------
# DynamoDB Table Manipulated by Lambda Function
# -----------------------------------------------------------------------------
resource "aws_dynamodb_table" "masseuse_table" {
  name = "${local.name}-masseuse"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "phone"

  attribute {
    name = "phone",
    type = "S"
  }
}

# -----------------------------------------------------------------------------
# Lambda Function to Test With
# -----------------------------------------------------------------------------
data "archive_file" "lambda" {
  type        = "zip"
  source_dir = "${path.module}/src"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_iam_role" "lambda" {
  name = "${local.name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "default" {
  filename         = "${data.archive_file.lambda.output_path}"
  function_name    = "${local.name}"
  role             = "${aws_iam_role.lambda.arn}"
  handler          = "main/lambda.myHandler"
  runtime          = "nodejs8.10"
  source_code_hash = "${base64sha256(file("${path.module}/src/main/lambda.js"))},"

  environment {
    variables = {
      LOG_LEVEL = "debug"
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.default.function_name}"
  retention_in_days = 7
}

resource "aws_iam_policy" "lambda_permissions" {
  name = "${local.name}"
  path = "/"
  description = "IAM policy allowing my Lambda to do its thing."

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "dynamodb:BatchGetItem",
        "dynamodb:BatchWriteItem",
        "dynamodb:DeleteItem",
        "dynamodb:DescribeStream",
        "dynamodb:DescribeTable",
        "dynamodb:GetItem",
        "dynamodb:GetRecords",
        "dynamodb:GetShardIterator",
        "dynamodb:PutItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:UpdateItem"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:dynamodb:*:*:table/kinesis-example-*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role = "${aws_iam_role.lambda.name}"
  policy_arn = "${aws_iam_policy.lambda_permissions.arn}"
}

# -----------------------------------------------------------------------------
# Expose Lambda as REST API
# -----------------------------------------------------------------------------
data "external" "populate_lambda_arn" {
  program = ["bash", "${path.module}/search_and_replace.sh"]

  query {
    input_file  = "${path.module}/swagger-template.yml"
    output_file  = "${path.module}/swagger.yml"
    search_text  = "LAMBDA_ARN"
    replace_text = "${aws_lambda_function.default.invoke_arn}"
  }
}

resource "aws_api_gateway_rest_api" "default" {
  name        = "${local.name}"
  description = "This is my API for demonstration purposes"
  endpoint_configuration = {
    types = ["REGIONAL"]
  }
  body = "${file(lookup(data.external.populate_lambda_arn.result, "output_file"))}"
}

resource "aws_api_gateway_deployment" "default" {
  rest_api_id = "${aws_api_gateway_rest_api.default.id}"
  stage_name  = "default"
}

resource "aws_lambda_permission" "lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.default.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.default.execution_arn}/*/*/*"
}

# Create S3 Bucket


# Create Kinesis Data Stream


# Subscribe Kinesis Data Stream to CloudWatch Event for lambda Logs


# Create Kinesis Firehose

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------
output "endpoint" {
  value = "${aws_api_gateway_deployment.default.invoke_url}"
}
