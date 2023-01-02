

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "0.0.0.0/0"
  availability_zone = "us-west-2a"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_network_interface" "foo" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_ami" "awsAmiEncrypted" {

  name = "some-name"

  ebs_block_device {
    device_name = "dev-name"
    encrypted   = "false"
  }
}

resource "aws_s3_bucket" "km_blob_storage" {
  bucket = "km-blob-storage-${var.environment}"
  acl    = "private"
  tags = merge(var.default_tags, {
    name = "km_blob_storage_${var.environment}"
  })

  versioning {
    mfa_delete = true
    enabled    = true
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = "<master_kms_key_id>"
      }
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_policy" "km_blob_storagepolicy" {
  bucket = aws_s3_bucket.km_blob_storage.id

  policy = <<POLICY
        {
            "Version": "2012-10-17",
            "Statement": [
              {
                  "Sid": "km_blob_storage-restrict-access-to-users-or-roles",
                  "Effect": "Allow",
                  "Principal": [
                    {
                       "AWS": [
                          "<aws_policy_role_arn>"
                        ]
                    }
                  ],
                  "Action": "s3:GetObject",
                  "Resource": "arn:aws:s3:::km_blob_storage/*"
              }
            ]
        }
    POLICY
}