output "glue_database_name" {
  value = aws_glue_catalog_database.health_lake.name
}

output "glue_crawler_name" {
  value = aws_glue_crawler.clean_zone.name
}

output "glue_crawler_arn" {
  value = aws_glue_crawler.clean_zone.arn
}

output "athena_workgroup_name" {
  value = aws_athena_workgroup.health_lake.name
}
