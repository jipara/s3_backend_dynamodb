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

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket-backend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetBucketVersioning"
        Resource  = aws_s3_bucket.bucket-backend.arn
      },
      {
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.bucket-backend.arn}/*"
        Condition = {
          StringEquals = {
            "s3:ExistingObjectTag/LockID" = "false"
          }
        }
      },
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = [
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource  = [
          "${aws_s3_bucket.bucket-backend.arn}/*",
          aws_s3_bucket.bucket-backend.arn
        ]
        Condition = {
          StringEquals = {
            "s3:ExistingObjectTag/LockID" = "true"
          }
        }
      }
    ]
  })
}
