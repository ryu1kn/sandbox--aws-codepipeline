output "key_arn" {
  value = data.aws_kms_alias.pipeline_test.arn
}
