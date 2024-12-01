provider "aws" {
  region                   = var.region
  shared_credentials_files = ["~/.aws/credentials"] # AWS CLIのcredentialsファイルから認証情報を取得
  profile                  = "default"              # AWS CLIのcredentialsファイルのプロファイル名
}

terraform {
  required_version = "~> 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


module "iam" {
  source = "../../modules/iam"
  name   = var.name
}

module "s3" {
  source = "../../modules/s3"
  name       = var.name
  force_destroy = true
}

module "lambda_s3_handler" {
  source = "../../modules/lambda_s3_handler"
  function_name = "s3_wav_transcriber"
  image_uri     = var.s3_wav_transcriber_image_uri
  role          = module.iam.lambda_role_arn
  bucket_name = module.s3.bucket_name
  source_arn    = module.s3.bucket_arn
  events        = ["s3:ObjectCreated:*"]
  filter_prefix = "inputs/"
  filter_suffix = ".wav"
}
