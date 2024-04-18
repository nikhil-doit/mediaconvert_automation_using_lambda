
####### Create Source S3 bucket for media files #######

module "src_bucket" {
  #Replace the URL with the link of S3 module
  source         = "./module_s3"
  s3-bucket-name = "my-mediaconvert-src-bucket"
  tags = {
    name       = "mediaconvert-src-bucket"
    env        = "test"
    created_by = "terraform"
  }
}

####### Create destination S3 bucket for converted media files #######

module "dst_bucket" {
  #Replace the URL with the link of S3 module
  source         = "./module_s3"
  s3-bucket-name = "my-mediaconvert-dst-bucket"
  tags = {
    name       = "mediaconvert-dest-bucket"
    env        = "test"
    created_by = "terraform"
  }
}

# policy can be passed in as data below or filepath
/*
data "aws_iam_policy_document" "default" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["mediaconvert.amazonaws.com"]
    }
  }
}
*/

####### Create MediaConvert role to process MediaConvert jobs #######

module "mediaconvert_role" {
  source             = "./module_iam_roles"
  role_name          = "mediaconvert_role"
  assume_role_policy = file("./policies_jsons/mediaconvert_role_policy.json")
  #assume_role_policy  = data.aws_iam_policy_document.default.json

  # AWS Managed policies needed for mediaconvert role.
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ]
  tags = {
    name       = "mediaconvert_role"
    env        = "test"
    created_by = "terraform"
  }
}

####### Create IAM role for lambda function #######

module "lambda_convert_role" {
  source             = "./module_iam_roles"
  role_name          = "lambda_convert_role"
  assume_role_policy = file("./policies_jsons/lambda_role_policy.json")
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
  ]
  tags = {
    name       = "lambda_convert_role",
    env        = "test"
    created_by = "terraform"
  }
}

####### Attach inline policy to lambda role  #######

resource "aws_iam_role_policy" "lambda_convert_inline" {
  name   = "lambda_convert_inline_policy"
  role   = module.lambda_convert_role.name
  policy = file("./policies_jsons/lambda_inline_policy.json")
}

####### Create lambda function  #######

#data "archive_file" "zip" {
#  type        = "zip"
#  source_file = "lambda_convert.py"
#  output_path = "./lambda_zip/lambda.zip"
#}

####### Deploy lambda function to trigger mediaconvert jobs on uploaded media files #######

resource "aws_lambda_function" "lambda_convert" {
  function_name = "mediaconvert_lambda"
  filename      = "./lambda_zip/mediaconvert_lambda.zip"
  description   = "lambda function triggers mediaconvert job on s3 PUT events"
  #filename         = data.archive_file.zip.output_path
  #source_code_hash = data.archive_file.zip.output_base64sha256
  role    = module.lambda_convert_role.arn
  handler = "mediaconvert_lambda.handler"
  runtime = "python3.8"
  environment {
    variables = {
      DestinationBucket = module.dst_bucket.bucket-name
      MediaConvertRole  = module.mediaconvert_role.arn
      Application       = var.app
    }
  }
  tags = {
    name       = "mediaconvert_lambda"
    env        = "test"
    created_by = "terraform"
  }

}
#######  Give an external source S3 (source bucket) permission to access the Lambda function #######
resource "aws_lambda_permission" "allow_source_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_convert.arn
  principal     = "s3.amazonaws.com"
  #source_arn    = module.src_bucket.bucket-name
}

####### Add trigger for mediacovert lambda function  #######
resource "aws_s3_bucket_notification" "lambdaconvert_trigger" {
  bucket = module.src_bucket.bucket-name

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_convert.arn
    events              = ["s3:ObjectCreated:*"]
    #filter_prefix       = "Mediafiles/"
    #filter_suffix       = ".mp4"
  }
}

####### Create SNS topic & email subscription #######
resource "aws_sns_topic" "MediaconvertNotification" {
  name = var.snstopic
}

resource "aws_sns_topic_subscription" "email-target" {
  topic_arn = aws_sns_topic.MediaconvertNotification.arn
  protocol  = "email"
  endpoint  = "nikhil@doit.com"
}

####### Create a CloudWatch Event Rule to monitor the status of MediaConvert jobs #######

resource "aws_cloudwatch_event_rule" "mediaconvert_rule" {
  name          = "mediaconvert_job_rule"
  description   = "Capture mediaconvert job status"
  event_pattern = file("./policies_jsons/cw_rule_mediaconver_job_policy.json")
}

####### Add SNS topic as target for cloudwatch event rule #######
resource "aws_cloudwatch_event_target" "sns_trigger" {
  rule      = aws_cloudwatch_event_rule.mediaconvert_rule.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.MediaconvertNotification.arn
}
####### SNS policy to allow eventbridge #######
resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.MediaconvertNotification.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.MediaconvertNotification.arn]
  }
}

####### Outputs  #######
output "mediaconvert_source_bucket" {
  value = module.src_bucket.bucket-name
}

output "mediaconvert_destimation_bucket" {
  value = module.dst_bucket.bucket-name
}

output "lambda_role_name" {
  value = module.lambda_convert_role.name
}

output "mediaconvert_role_name" {
  value = module.mediaconvert_role.name
}

output "lambda_inline_policy" {
  value = aws_iam_role_policy.lambda_convert_inline.name
}

output "lambda_function" {
  value = aws_lambda_function.lambda_convert.function_name
}

output "sns_topic" {
  value = aws_sns_topic.MediaconvertNotification.name
}

output "mediaconvert_src_bucket" {
  value = module.src_bucket.bucket-name
}

output "lambda_role_arn" {
  value = module.lambda_convert_role.arn
}

output "mediaconvert_lambda_arn" {
  value = aws_lambda_function.lambda_convert.arn
}

output "mediaconvert_role_arn" {
  value = module.mediaconvert_role.arn
}
