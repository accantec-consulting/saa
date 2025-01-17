resource "aws_iam_role" "bedrock_kb_this_kb" {
  name = "AmazonBedrockExecutionRoleForKnowledgeBase_${var.kb_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:${local.partition}:bedrock:${local.region}:${local.account_id}:knowledge-base/*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "bedrock_kb_this_kb_model" {
  name = "AmazonBedrockFoundationModelPolicyForKnowledgeBase_${var.kb_name}"
  role = aws_iam_role.bedrock_kb_this_kb.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "bedrock:InvokeModel"
        Effect   = "Allow"
        Resource = data.aws_bedrock_foundation_model.kb.model_arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "bedrock_kb_this_kb_s3" {
  name = "AmazonBedrockS3PolicyForKnowledgeBase_${var.kb_name}"
  role = aws_iam_role.bedrock_kb_this_kb.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "S3ListBucketStatement"
        Action   = "s3:ListBucket"
        Effect   = "Allow"
        Resource = aws_s3_bucket.this_kb.arn
        Condition = {
          StringEquals = {
            "aws:PrincipalAccount" = local.account_id
          }
        }
      },
      {
        Sid      = "S3GetObjectStatement"
        Action   = "s3:GetObject"
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.this_kb.arn}/*"
        Condition = {
          StringEquals = {
            "aws:PrincipalAccount" = local.account_id
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "bedrock_agent_this_asst" {
  name = "AmazonBedrockExecutionRoleForAgents_${var.agent_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:${local.partition}:bedrock:${local.region}:${local.account_id}:agent/*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "bedrock_agent_this_asst_model" {
  name = "AmazonBedrockAgentBedrockFoundationModelPolicy_${var.agent_name}"
  role = aws_iam_role.bedrock_agent_this_asst.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "bedrock:InvokeModel"
        Effect   = "Allow"
        Resource = data.aws_bedrock_foundation_model.agent.model_arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "bedrock_agent_this_asst_kb" {
  name = "AmazonBedrockAgentBedrockKnowledgeBasePolicy_${var.agent_name}"
  role = aws_iam_role.bedrock_agent_this_asst.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "bedrock:Retrieve"
        Effect   = "Allow"
        Resource = aws_bedrockagent_knowledge_base.this_kb.arn
      }
    ]
  })
}

resource "aws_iam_role" "lambda_this_api" {
  name = "FunctionExecutionRoleForLambda_${var.action_group_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
          }
        }
      }
    ]
  })
  managed_policy_arns = [data.aws_iam_policy.lambda_basic_execution.arn]
}

resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "SAA-Bedrock-SecretsManagerPolicy"
  description = "Policy granting access to Secrets Manager for Bedrock role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.pinecone_api_key.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_secrets_manager_policy" {
  role       = aws_iam_role.bedrock_kb_this_kb.name
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_secrets_manager_policy2" {
  role       = aws_iam_role.bedrock_agent_this_asst.name
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
}

resource "aws_iam_role" "saa-ec2-role" {
  name = "SAA-EC2-Streamlit-Frontend-EC2Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  max_session_duration = 3600
  path                 = "/"
}

resource "aws_iam_instance_profile" "saa-instance-profile" {
  name = "SAA-EC2-Streamlit-Frontend-InstanceProfile"
  role = aws_iam_role.saa-ec2-role.name
}

resource "aws_iam_role" "saa-invoke-bedrock-role" {
  name = "saa-invokeBedrockAgent-v1"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  max_session_duration = 3600
  path                 = "/service-role/"
}

resource "aws_iam_policy" "api_gateway_invoke_full_access" {
  name        = "APIGatewayInvokeFullAccessPolicy"
  description = "Provides full access to API Gateway invoke actions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "apigateway:POST"
        Resource = "*"
        Effect   = "Allow"
      },
      {
        Action   = "apigateway:GET"
        Resource = "*"
        Effect   = "Allow"
      },
      {
        Action   = "apigateway:DELETE"
        Resource = "*"
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_policy" "bedrock_full_access" {
  name        = "BedrockFullAccessPolicy"
  description = "Provides full access to Bedrock"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "cloudwatch_logs_access" {
  name        = "CloudWatchLogsAccess"
  description = "Full access to CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "logs:*"
        Resource = "*"
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_attach" {
  policy_arn = aws_iam_policy.api_gateway_invoke_full_access.arn
  role       = aws_iam_role.saa-invoke-bedrock-role.name
}

resource "aws_iam_role_policy_attachment" "bedrock_attach" {
  policy_arn = aws_iam_policy.bedrock_full_access.arn
  role       = aws_iam_role.saa-invoke-bedrock-role.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs_attach" {
  policy_arn = aws_iam_policy.cloudwatch_logs_access.arn
  role       = aws_iam_role.saa-invoke-bedrock-role.name
}

resource "aws_iam_role" "eventbridge_ec2_role" {
  name = "EventBridgeEC2Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          Service : "scheduler.amazonaws.com"
        },
        Action : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ec2_start_stop_policy" {
  name        = "EC2StartStopPolicy"
  description = "Erlaubt das Starten und Stoppen der spezifischen EC2-Instanz"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "ec2:StartInstances",
          "ec2:StopInstances"
        ],
        Resource : aws_instance.ec2-streamlit-app.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ec2_start_stop_policy" {
  role       = aws_iam_role.eventbridge_ec2_role.name
  policy_arn = aws_iam_policy.ec2_start_stop_policy.arn
}
