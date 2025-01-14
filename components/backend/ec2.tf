resource "aws_instance" "ec2-streamlit-app" {
  ami                         = "ami-0e2c8caa4b6378d8c" #ami in jeder Region unterschiedlich
  instance_type               = "t3.small"
  availability_zone           = aws_subnet.saa-subnet.availability_zone
  associate_public_ip_address = true
  disable_api_stop            = false
  disable_api_termination     = false
  ebs_optimized               = true
  monitoring                  = true
  tenancy                     = "default"
  subnet_id                   = aws_subnet.saa-subnet.id
  vpc_security_group_ids      = [aws_security_group.saa-sg.id]
  iam_instance_profile        = aws_iam_instance_profile.saa-instance-profile.name

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = 8
    volume_type           = "gp2"
  }

  user_data = file("${path.module}/../../saa_frontend/user_data.sh")

  tags = {
    Name = "EC2-Streamlit-App"
  }
}

resource "aws_eip" "ec2_streamlit_app" {
  instance = aws_instance.ec2-streamlit-app.id
  domain   = "vpc"
}
