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

  # 💡 Explicit dummy keys to force offline planning in blank CI environments
  access_key = "mock_access_key"
  secret_key = "mock_secret_key"

  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

# 🚨 Security Flaw #1: Publicly accessible S3 Bucket
resource "aws_s3_bucket" "public_data" {
  bucket = "company-confidential-data-2026"
}

resource "aws_s3_bucket_public_access_block" "bad_practice" {
  bucket = aws_s3_bucket.public_data.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 🚨 Security Flaw #2: SSH Open to the whole internet
resource "aws_security_group" "allow_ssh_global" {
  name        = "allow_ssh"
  description = "Insecure security group"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to the world!
  }
}
