resource "aws_s3_bucket" "this"{
  bucket = var.name
  force_destroy = var.force_destroy
}