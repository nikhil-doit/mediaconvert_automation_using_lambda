output "arn" {
  value       = join("", aws_iam_role.default.*.arn)
  description = "The Amazon Resource Name (ARN) specifying the role."
}

output "name" {
  value       = join("", aws_iam_role.default.*.name)
  description = "Name of specifying the role."
}
