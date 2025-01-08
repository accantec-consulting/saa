data "aws_caller_identity" "this" {}
data "aws_partition" "this" {}
data "aws_region" "this" {}

data "aws_bedrock_foundation_model" "agent" {
  model_id = var.agent_model_id
}

data "aws_bedrock_foundation_model" "kb" {
  model_id = var.kb_model_id
}

data "aws_iam_policy" "lambda_basic_execution" {
  name = "AWSLambdaBasicExecutionRole"
}

data "archive_file" "this_api_zip" {
  type             = "zip"
  source_file      = "${path.module}/lambda/this_api/index.py"
  output_path      = "${path.module}/tmp/this_api.zip"
  output_file_mode = "0666"
}
