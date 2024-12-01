resource "aws_lambda_function" "s3_handler" {
  package_type  = "Image"
  function_name = var.function_name
  image_uri     = var.image_uri
  role          = var.role
}

resource "aws_s3_bucket_notification" "s3_notification" {
  bucket = var.bucket_name
  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_handler.arn
    events              = var.events
    filter_prefix       = var.filter_prefix
    filter_suffix       = var.filter_suffix
  }
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  principal     = "s3.amazonaws.com"
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_handler.function_name
  source_arn    = var.source_arn
}