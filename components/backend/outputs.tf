output "s3_bucket_id" {
  description = "The ID of the S3 bucket used for the knowledge base."
  value       = aws_s3_bucket.this_kb.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket used for the knowledge base."
  value       = aws_s3_bucket.this_kb.arn
}

output "lambda_function_name" {
  description = "The name of the Lambda function."
  value       = aws_lambda_function.this_api.function_name
}

output "lambda_function_arn" {
  description = "The ARN of the Lambda function."
  value       = aws_lambda_function.this_api.arn
}

output "agent_id" {
  description = "The ID of the Bedrock agent."
  value       = aws_bedrockagent_agent.this_asst.id
}

output "knowledge_base_id" {
  description = "The ID of the Bedrock knowledge base."
  value       = aws_bedrockagent_knowledge_base.this_kb.id
}

output "knowledge_base_arn" {
  description = "The ARN of the Bedrock knowledge base."
  value       = aws_bedrockagent_knowledge_base.this_kb.arn
}
