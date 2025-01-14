resource "aws_api_gateway_rest_api" "saa-api" {
  name              = "saa-api-lambda"
  api_key_source    = "HEADER"
  description       = "API to connect Streamlit Frontend with Lambda to invoke agent."
  put_rest_api_mode = "overwrite"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_request_validator" "validate-body" {
  name                  = "validate body"
  rest_api_id           = aws_api_gateway_rest_api.saa-api.id
  validate_request_body = true
}

resource "aws_api_gateway_method" "post" {
  operation_name   = "GetAnswer"
  rest_api_id      = aws_api_gateway_rest_api.saa-api.id
  resource_id      = aws_api_gateway_rest_api.saa-api.root_resource_id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = false

  request_models = {
    "application/json" = "Empty"
  }
  request_validator_id = aws_api_gateway_request_validator.validate-body.id
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id             = aws_api_gateway_rest_api.saa-api.id
  resource_id             = aws_api_gateway_rest_api.saa-api.root_resource_id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = aws_api_gateway_method.post.http_method
  type                    = "AWS"
  content_handling        = "CONVERT_TO_TEXT"
  passthrough_behavior    = "WHEN_NO_MATCH"
  timeout_milliseconds    = 60000

  uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.saa-invoke-agent.arn}/invocations"
}

resource "aws_api_gateway_integration_response" "post" {
  rest_api_id = aws_api_gateway_rest_api.saa-api.id
  resource_id = aws_api_gateway_rest_api.saa-api.root_resource_id
  http_method = aws_api_gateway_method.post.http_method

  response_templates = {
    "application/json" = ""
  }
  status_code = jsonencode(200)
}

resource "aws_api_gateway_method_response" "post" {
  rest_api_id = aws_api_gateway_rest_api.saa-api.id
  resource_id = aws_api_gateway_rest_api.saa-api.root_resource_id
  http_method = aws_api_gateway_method.post.http_method

  response_models = {
    "application/json" = "Empty"
  }
  status_code = jsonencode(200)
}

resource "aws_api_gateway_deployment" "dev" {
  rest_api_id = aws_api_gateway_rest_api.saa-api.id
}

resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.dev.id
  rest_api_id   = aws_api_gateway_rest_api.saa-api.id
  stage_name    = "dev"
}
