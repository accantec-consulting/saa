resource "aws_lambda_function" "this_api" {
  function_name    = var.action_group_name
  role             = aws_iam_role.lambda_this_api.arn
  description      = "A Lambda function for the action group ${var.action_group_name}"
  filename         = data.archive_file.this_api_zip.output_path
  handler          = "index.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.this_api_zip.output_base64sha256
  depends_on       = [aws_iam_role.lambda_this_api]
}

resource "aws_lambda_permission" "this_api" {
  action         = "lambda:invokeFunction"
  function_name  = aws_lambda_function.this_api.function_name
  principal      = "bedrock.amazonaws.com"
  source_account = local.account_id
  source_arn     = "arn:${local.partition}:bedrock:${local.region}:${local.account_id}:agent/*"
}

resource "aws_lambda_function" "saa-invoke-agent" {
  function_name = "saa-invokeBedrockAgent"
  role          = aws_iam_role.saa-invoke-bedrock-role.arn
  filename      = data.archive_file.saa-invoke-agent_zip.output_path
  handler       = "saa-invoke-agent.lambda_handler"
  memory_size   = 128
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 60
  environment {
    variables = {
      AGENT_ALIAS_ID = aws_bedrockagent_agent_alias.this_asst.id
      AGENT_ID       = aws_bedrockagent_agent.this_asst.id
    }
  }
  ephemeral_storage {
    size = 512
  }
  logging_config {
    log_format = "Text"
    log_group  = "/aws/lambda/saa-invokeBedrockAgent"
  }
}
