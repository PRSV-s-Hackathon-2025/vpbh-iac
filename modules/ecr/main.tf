resource "aws_ecr_repository" "api" {
  name                 = "vpbh-bigdata-api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}