output "function_name" {
    value = aws_lambda_function.s3_handler.function_name
    description = "The name of the Lambda function"
}

output "function_arn" {
    value = aws_lambda_function.s3_handler.arn
    description = "The ARN of the Lambda function"
}
