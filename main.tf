terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  # Explicit dummy keys for offline planning in blank CI environments
  access_key = "mock_access_key"
  secret_key = "mock_secret_key"

  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

# 🔒 SECURED: S3 public access blocks are now explicitly set to TRUE
resource "aws_s3_bucket" "public_data" {
  bucket = "company-confidential-data-2026"
}

resource "aws_s3_bucket_public_access_block" "bad_practice" {
  bucket = aws_s3_bucket.public_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 🔒 SECURED: Port 22 is no longer open to the whole internet (0.0.0.0/0)
resource "aws_security_group" "allow_ssh_global" {
  name        = "allow_ssh"
  description = "Secure corporate security group"

  ingress {
    description = "SSH from internal corporate network only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Restricted to private internal space
  }
}
