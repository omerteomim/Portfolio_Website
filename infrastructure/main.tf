terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "omer-state-tf"
    key            = "ContactForm/terraform.tfstate"
    region         = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

# SNS Topic for contact form submissions
resource "aws_sns_topic" "contact_form_submissions" {
  name = "ContactForm"
}

# SNS Topic Subscription
resource "aws_sns_topic_subscription" "email_notification" {
  topic_arn = aws_sns_topic.contact_form_submissions.arn
  protocol  = "email"
  endpoint  = var.your_email
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "contact-form-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "contact-form-lambda-policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["sns:Publish"]
        Resource = aws_sns_topic.contact_form_submissions.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_lambda_function" "contact_form_handler" {
  filename         = var.lambda_zip_path
  function_name    = "contact-form-handler"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  timeout          = 5

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.contact_form_submissions.arn
    }
  }
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "contact-form-http-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_methods     = ["POST", "OPTIONS"]
    allow_origins     = ["*"]
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token"]
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.contact_form_handler.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "contact_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromHttpApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.contact_form_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

output "api_gateway_url" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}
