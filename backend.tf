terraform {
  backend "s3" {
    bucket         = "saa-tf-state-bucket"
    key            = "terraform.tfstate"
    encrypt        = true
    region         = "us-east-1"
    dynamodb_table = "saa-dynamodb-state-locking"
  }
}
