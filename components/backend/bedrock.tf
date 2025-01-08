locals {
  account_id            = data.aws_caller_identity.this.account_id
  partition             = data.aws_partition.this.partition
  region                = data.aws_region.this.name
  region_name_tokenized = split("-", local.region)
  region_short          = "${substr(local.region_name_tokenized[0], 0, 2)}${substr(local.region_name_tokenized[1], 0, 1)}${local.region_name_tokenized[2]}"
}

resource "aws_bedrockagent_knowledge_base" "this_kb" {
  name     = var.kb_name
  role_arn = aws_iam_role.bedrock_kb_this_kb.arn
  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = data.aws_bedrock_foundation_model.kb.model_arn
    }
    type = "VECTOR"
  }
  storage_configuration {
    type = "PINECONE"
    pinecone_configuration {
      connection_string      = "https://test-sve0gl2.svc.aped-4627-b74a.pinecone.io"
      credentials_secret_arn = aws_secretsmanager_secret.pinecone_api_key.arn
      field_mapping {
        text_field     = "AMAZON_BEDROCK_TEXT_CHUNK"
        metadata_field = "AMAZON_BEDROCK_METADATA"
      }
      namespace = "default"
    }
  }
  depends_on = [
    aws_iam_role_policy.bedrock_kb_this_kb_model,
    aws_iam_role_policy.bedrock_kb_this_kb_s3
  ]
}

resource "aws_bedrockagent_data_source" "this_kb" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.this_kb.id
  name              = "${var.kb_name}DataSource"
  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = aws_s3_bucket.this_kb.arn
    }
  }
}

resource "aws_bedrockagent_agent" "this_asst" {
  agent_name              = var.agent_name
  agent_resource_role_arn = aws_iam_role.bedrock_agent_this_asst.arn
  description             = var.agent_desc
  foundation_model        = data.aws_bedrock_foundation_model.agent.model_id
  instruction             = file("${path.module}/prompt_templates/instruction.txt")
  depends_on = [
    aws_iam_role_policy.bedrock_agent_this_asst_kb,
    aws_iam_role_policy.bedrock_agent_this_asst_model
  ]
}

resource "aws_bedrockagent_agent_action_group" "this_api" {
  action_group_name          = var.action_group_name
  agent_id                   = aws_bedrockagent_agent.this_asst.id
  agent_version              = "DRAFT"
  description                = var.action_group_desc
  skip_resource_in_use_check = true
  action_group_executor {
    lambda = aws_lambda_function.this_api.arn
  }
  api_schema {
    payload = file("${path.module}/lambda/this_api/schema.yaml")
  }
}

resource "aws_bedrockagent_agent_knowledge_base_association" "this_kb" {
  agent_id             = aws_bedrockagent_agent.this_asst.id
  description          = file("${path.module}/prompt_templates/kb_instruction.txt")
  knowledge_base_id    = aws_bedrockagent_knowledge_base.this_kb.id
  knowledge_base_state = "ENABLED"
}

resource "null_resource" "this_asst_prepare" {
  triggers = {
    this_api_state = sha256(jsonencode(aws_bedrockagent_agent_action_group.this_api))
    this_kb_state  = sha256(jsonencode(aws_bedrockagent_knowledge_base.this_kb))
  }
  provisioner "local-exec" {
    command = "aws bedrock-agent prepare-agent --agent-id ${aws_bedrockagent_agent.this_asst.id}"
  }
  depends_on = [
    aws_bedrockagent_agent.this_asst,
    aws_bedrockagent_agent_action_group.this_api,
    aws_bedrockagent_knowledge_base.this_kb,
    time_sleep.wait_for_agent_creation
  ]
}

#Wartezeit auf Agent für Prepare
resource "time_sleep" "wait_for_agent_creation" {
  create_duration = "30s"
  depends_on      = [aws_bedrockagent_agent.this_asst]
}

# Beim nächsten Neu-Aufsetzen entkommentieren
# resource "time_sleep" "wait_for_bedrock_kb_role" {
#   create_duration = "30s"
#   depends_on      = [aws_iam_role.bedrock_kb_this_kb]
# }
