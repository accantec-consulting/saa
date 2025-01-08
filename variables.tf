variable "s3_bucket_name_prefix" {
  description = "The name prefix of the S3 bucket for the data source of the knowledge base."
  type        = string
  default     = "this-kb"
}

variable "oss_collection_name" {
  description = "The name of the OSS collection for the knowledge base."
  type        = string
  default     = "bedrock-knowledge-base-this-kb"
}

variable "kb_model_id" {
  description = "The ID of the foundational model used by the knowledge base."
  type        = string
  default     = "amazon.titan-embed-text-v1"
}

variable "kb_name" {
  description = "The knowledge base name."
  type        = string
  default     = "ThisKB"
}

variable "agent_model_id" {
  description = "The ID of the foundational model used by the agent."
  type        = string
  default     = "anthropic.claude-3-haiku-20240307-v1:0"
}

variable "agent_name" {
  description = "The agent name."
  type        = string
  default     = "ThisAssistant"
}

variable "action_group_name" {
  description = "The action group name."
  type        = string
  default     = "ThisAPI"
}

variable "pineconeAPI" { # als Umgebungsvariable gespeichert
  description = "Pinecone API Key stored as an environment variable"
  type        = string
  sensitive   = true
}
