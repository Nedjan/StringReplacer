provider "aws" {
  region = "eu-central-1"
  profile = "personal"
}
# Create role for lambda functions
resource "aws_iam_role" "lambda_role" {
name = "String_Replacer_Function_Role"
assume_role_policy=<<EOF
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

resource "aws_iam_policy" "iam_policy_for_string_replacer" {
name = "aws_iam_policy_for_terraform_aws_lambda_role"
path = "/"
description = "AWS IAM Policy for managing aws lambda role"
policy=<<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_string_replacer.arn
}

# archive the lambda function into the string-replacer zip file
data "archive_file" "zip_string_replacer_function" {
  type = "zip"
  source_dir = "${path.module}/../src/"
  output_path = "${path.module}/out/string-replacer.zip"
}

# define lambda function
resource "aws_lambda_function" "string-replacer-function" {
  filename = "${path.module}/out/string-replacer.zip"
  function_name = "String_Replacer_Lambda_Function"
  role = aws_iam_role.lambda_role.arn
  handler = "string_replacer.lambda_handler"
  runtime = "ruby2.7"
  source_code_hash = filebase64sha256("${path.module}/out/string-replacer.zip")
  architectures = ["x86_64"]
  environment {
    variables = {
      dictionary = jsonencode({
        "Oracle": "Oracle©",
        "Google": "Google©",
        "Microsoft": "Microsoft©",
        "Amazon": "Amazon©",
        "Deloitte": "Deloitte©"
      })
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role
  ]
}

# defines a name for the api gateway and sets its protocol to http
resource "aws_apigatewayv2_api" "string-replacer-api" {
  name = "serverless_lambda_gw"
  protocol_type = "HTTP"
}

# sets up stage application for our API gateway
resource "aws_apigatewayv2_stage" "stage" {
  api_id = aws_apigatewayv2_api.string-replacer-api.id
  name = "serverless_lambda_stage"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

# configures the gateway to use the lambda function
resource "aws_apigatewayv2_integration" "string-replacer-integration" {
  api_id = aws_apigatewayv2_api.string-replacer-api.id

  integration_uri = aws_lambda_function.string-replacer-function.invoke_arn
  integration_type = "AWS_PROXY"
  integration_method = "POST"
}

# sets up the string-replacer route
resource "aws_apigatewayv2_route" "string-replacer" {
  api_id = aws_apigatewayv2_api.string-replacer-api.id

  route_key = "GET /string-replacer"
  target = "integrations/${aws_apigatewayv2_integration.string-replacer-integration.id}"
}

# adds logging for the stage
resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.string-replacer-api.name}"

  retention_in_days = 30
}

# give permission to the api gateway to invoke the lambda function
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.string-replacer-function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.string-replacer-api.execution_arn}/*/*"
}
