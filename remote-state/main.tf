provider "aws" {
  region  = "us-east-1"
  profile = "development"
}

resource "aws_s3_bucket" "terra_state" {
  bucket = var.bucket_name // read from vars.tf
  /* Don't do this in prod
  Indicates all objs should be deleted so that bucket can be destroyed w/o error
  */
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terra_state.id // Pointer to the above defined bucket

  versioning_configuration {
    status = "Enabled" // Best practices, updating file in bucket creates new version. Sort of like Git
  }
}

// Enable default server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terra_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" // Only the best :p
    }
  }
}
