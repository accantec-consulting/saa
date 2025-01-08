resource "aws_secretsmanager_secret" "pinecone_api_key" {
  name        = "pinecone-api-key123"
  description = "Pinecone API Key for Bedrock Knowledge Base"
}

resource "aws_secretsmanager_secret_version" "pinecone_api_key_version" {
  secret_id = aws_secretsmanager_secret.pinecone_api_key.id

  secret_string = jsonencode({
    apiKey = var.pineconeAPI
  })
}
