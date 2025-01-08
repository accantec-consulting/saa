resource "aws_s3_bucket" "this_kb" {
  bucket        = "${var.s3_bucket_name_prefix}-${local.region_short}-${local.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this_kb" {
  bucket = aws_s3_bucket.this_kb.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "this_kb" {
  bucket = aws_s3_bucket.this_kb.id
  versioning_configuration {
    status = "Enabled"
  }
  depends_on = [aws_s3_bucket_server_side_encryption_configuration.this_kb]
}
