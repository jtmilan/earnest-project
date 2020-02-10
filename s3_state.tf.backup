resource "aws_s3_bucket" "iac-cluster-state" {
  bucket = "iac-cluster-tfstate"
  # Enable versioning so we can see the full revision history of our
  # state files
  
   # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "iac-cluster-locks" {
  name         = "iac-cluster-tfstate-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    # Replace this with your bucket name!
    key        = "global/s3/terraform.tfstate"
  }
}
