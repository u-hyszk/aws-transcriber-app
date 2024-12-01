variable "name" {
  type   = string
  description = "The name of the environment"
}

variable "region" {
  type   = string
  description = "The region in which the resources will be created"
}

variable "s3_wav_transcriber_image_uri" {
  type   = string
  description = "The URI of the 's3_wav_transcriber' container image"
}
