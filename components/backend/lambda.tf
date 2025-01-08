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
