module "backend" {
  source = "./components/backend"

  s3_bucket_name_prefix = var.s3_bucket_name_prefix
  oss_collection_name   = var.oss_collection_name
  kb_model_id           = var.kb_model_id
  kb_name               = var.kb_name
  agent_model_id        = var.agent_model_id
  agent_name            = var.agent_name
  action_group_name     = var.action_group_name
  pineconeAPI           = var.pineconeAPI
}
