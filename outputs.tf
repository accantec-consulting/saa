output "s3_bucket_id" {
  description = "The ID of the S3 bucket used for the knowledge base."
  value       = module.backend.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket used for the knowledge base."
  value       = module.backend.s3_bucket_arn
}

output "lambda_function_name" {
  description = "The name of the Lambda function."
  value       = module.backend.lambda_function_name
}

output "lambda_function_arn" {
  description = "The ARN of the Lambda function."
  value       = module.backend.lambda_function_arn
}

output "agent_id" {
  description = "The ID of the Bedrock agent."
  value       = module.backend.agent_id
}

output "knowledge_base_id" {
  description = "The ID of the Bedrock knowledge base."
  value       = module.backend.knowledge_base_id
}

output "knowledge_base_arn" {
  description = "The ARN of the Bedrock knowledge base."
  value       = module.backend.knowledge_base_arn
}
