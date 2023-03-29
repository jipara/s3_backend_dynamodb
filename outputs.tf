output "dynamodb_table_name" {
  value = aws_dynamodb_table.table_for_s3.name
}
