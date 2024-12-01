
# ---  Required  --- #

variable "function_name" {
    type = string
    description = "The name of the Lambda function"
}

variable "image_uri" {
    type = string
    description = "The URI of the container image"
}

variable "role" {
    type = string
    description = "The ARN of the IAM role that the Lambda function assumes when it executes"
}

variable "bucket_name" {
    type = string
    description = "The name of the S3 bucket to receive notifications"
}

variable "source_arn" {
    type = string
    description = "The ARN of the S3 bucket to receive notifications"
}

# --- Optional --- #

variable "events" {
    type = list(string)
    description = "A list of S3 event types"
    default = []
}

variable "filter_prefix" {
    type = string
    description = "The prefix filter"
    default = ""
}

variable "filter_suffix" {
    type = string
    description = "The suffix filter"
    default = ""
}
