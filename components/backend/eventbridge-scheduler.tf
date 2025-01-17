resource "aws_scheduler_schedule_group" "ec2-scheduler-group" {
  name = "ec2-scheduler-group"
}

resource "aws_scheduler_schedule" "start" {
  name        = "StartEC2Instance"
  group_name  = aws_scheduler_schedule_group.ec2-scheduler-group.name
  description = "Rule to start EC2 Instance on Workdays."

  schedule_expression          = "cron(07 00 ? * MON-FRI *)"
  schedule_expression_timezone = "Europe/Berlin"
  state                        = var.schedule_state #derzeit DISABLED, aber ENABLED beim realen Deployment
  flexible_time_window {
    mode = "OFF"
  }
  target {
    arn = "arn:aws:scheduler:::aws-sdk:ec2:startInstances"
    input = jsonencode({
      InstanceIds = [aws_instance.ec2-streamlit-app.id]
    })
    role_arn = aws_iam_role.eventbridge_ec2_role.arn
    retry_policy {
      maximum_event_age_in_seconds = 1800
      maximum_retry_attempts       = 2
    }
  }
}

resource "aws_scheduler_schedule" "stop" {
  name        = "StopEC2Instance"
  group_name  = aws_scheduler_schedule_group.ec2-scheduler-group.name
  description = "Rule to stop EC2 Instance on Workdays."

  schedule_expression          = "cron(19 00 ? * MON-FRI *)"
  schedule_expression_timezone = "Europe/Berlin"
  state                        = var.schedule_state #derzeit DISABLED, aber ENABLED beim realen Deployment
  flexible_time_window {
    mode = "OFF"
  }
  target {
    arn = "arn:aws:scheduler:::aws-sdk:ec2:stopInstances"
    input = jsonencode({
      InstanceIds = [aws_instance.ec2-streamlit-app.id]
    })
    role_arn = aws_iam_role.eventbridge_ec2_role.arn
    retry_policy {
      maximum_event_age_in_seconds = 1800
      maximum_retry_attempts       = 2
    }
  }
}
