variable "s3-bucket-name" {
  description = "Name of the S3 bucket"
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the bucket."
  type        = map(string)
  default     = {}
}