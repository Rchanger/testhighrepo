

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

  name                = "some-name"

  ebs_block_device {
    device_name = "dev-name"
    encrypted = "false"
  }
}

resource "aws_s3_bucket" "km_blob_storage" {
  bucket = "km-blob-storage-${var.environment}"
  acl    = "private"
  tags = merge(var.default_tags, {
    name = "km_blob_storage_${var.environment}"
  })
}
