resource "aws_acm_certificate" "roboshop" {
  domain_name       = "*.${var.domain_name}"
  validation_method = "DNS"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

output "certificate_arn" {
  value = aws_acm_certificate.roboshop.arn
}

output "acm_validation_records" {
  value = [
    for dvo in aws_acm_certificate.roboshop.domain_validation_options : {
      domain = dvo.domain_name
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      value  = dvo.resource_record_value
    }
  ]
}