variable "lambda_package_file" {
  type = string
}

provider "aws" {
  version = "~> 2.51.0"
  region = "ap-southeast-2"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_api_gateway_rest_api" "my_app" {
  name = "my_app"

  body = <<EOF
{
  "swagger": "2.0",
  "info": {
    "version": "2017-02-25T13:40:34Z",
    "title": "CodePipeline Test API"
  },
  "schemes": ["https"],
  "paths": {
    "/{proxy+}": {
      "x-amazon-apigateway-any-method": {
        "produces": [
          "application/json"
        ],
        "parameters": [
          {
            "name": "proxy",
            "in": "path",
            "required": true,
            "type": "string"
          }
        ],
        "responses": {},
        "security": [
          {
            "default-authorizer": []
          }
        ],
        "x-amazon-apigateway-integration": {
          "responses": {
            "default": {
              "statusCode": "200"
            }
          },
          "uri": "${aws_lambda_function.my_app.invoke_arn}",
          "passthroughBehavior": "when_no_match",
          "httpMethod": "POST",
          "cacheNamespace": "borr54",
          "cacheKeyParameters": [
            "method.request.path.proxy"
          ],
          "contentHandling": "CONVERT_TO_TEXT",
          "type": "aws_proxy"
        }
      }
    }
  },
  "definitions": {
    "Empty": {
      "type": "object",
      "title": "Empty Schema"
    }
  }
}
EOF
}

resource "aws_api_gateway_stage" "my_app" {
  stage_name    = "default"
  rest_api_id   = aws_api_gateway_rest_api.my_app.id
  deployment_id = aws_api_gateway_deployment.my_app.id
}

resource "aws_api_gateway_method_settings" "my_app" {
  rest_api_id = aws_api_gateway_rest_api.my_app.id
  stage_name  = aws_api_gateway_stage.my_app.stage_name
  method_path = "/*/*"  # Maybe "*/*"

  settings {
    throttling_rate_limit = 10
    throttling_burst_limit = 20
  }
}

resource "aws_api_gateway_deployment" "my_app" {
  rest_api_id = aws_api_gateway_rest_api.my_app.id
}

resource "aws_iam_role" "my_app_lambda" {
  name = "my_app_lambda"

  assume_role_policy = <<-EOF
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

resource "aws_iam_role_policy" "my_app_lambda" {
  name = "my_app_lambda"
  role = aws_iam_role.my_app_lambda.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "cloudwatch:*"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "kms:Describe*",
          "kms:Get*",
          "kms:List*"
        ],
        "Resource": "*"
      }
    ]
  }
  EOF
}

resource "aws_lambda_function" "my_app" {
  filename      = var.lambda_package_file
  function_name = "pipeline-test-proxy"
  role          = aws_iam_role.my_app_lambda.arn
  handler       = "index.handler"
  runtime = "nodejs10.x"
  source_code_hash = filebase64sha256(var.lambda_package_file)
}

resource "aws_lambda_permission" "my_app" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_app.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.my_app.id}/*"
}

resource "aws_cloudwatch_log_group" "my_app_lambda" {
  name = "/aws/lambda/${aws_lambda_function.my_app.function_name}"
  retention_in_days = 14
}

output "gateway-endpoint" {
  value = "${aws_api_gateway_rest_api.my_app.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.my_app.stage_name}"
}
