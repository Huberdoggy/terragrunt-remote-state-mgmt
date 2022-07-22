provider "aws" {
  region  = "us-east-1"
  profile = "development"
}

resource "aws_s3_bucket" "terra_state" {
  bucket = "${var.bucket_name}" // read from vars.tf

  versioning {
    enabled = true // Best practices, updating file in bucket creates new version. Sort of like Git
  }

  force_destroy = true // Force removal of all files/versions from bucket to prevent errors when I'm done
  /*
  lifecycle { // setting this will cause 'terraform destroy' to error
  prevent_destroy = true
  }
  */
}

  
