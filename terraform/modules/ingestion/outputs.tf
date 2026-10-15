output "ingest_lambda_arn" {
  value = aws_lambda_function.ingest.arn
}

output "ingest_lambda_name" {
  value = aws_lambda_function.ingest.function_name
}

output "ingest_role_arn" {
  value = aws_iam_role.ingest.arn
}

output "clean_lambda_arn" {
  value = aws_lambda_function.clean.arn
}

output "clean_lambda_name" {
  value = aws_lambda_function.clean.function_name
}

output "clean_role_arn" {
  value = aws_iam_role.clean.arn
}

output "reporting_role_arn" {
  value = aws_iam_role.reporting.arn
}
