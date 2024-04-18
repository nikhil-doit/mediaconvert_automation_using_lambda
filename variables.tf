variable "AWS_ACCESS_KEY_ID" {
  description = "AWS Access Key ID"
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS Secret Access Key"
}

variable "app" {
  default = "mediaconvert_automation"
}

variable "snstopic" {
  default = "mediaconvert_job_notification"
}
