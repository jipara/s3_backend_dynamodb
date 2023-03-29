provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "bucket-backend" {
  bucket = "bucket-backend-terra"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    LockID = "false"
  }
}

resource "aws_dynamodb_table" "table_for_s3" {
  name         = "table_for_s3"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  key_schema {
    attribute_name = "LockID"
    key_type       = "HASH"
  }
}
