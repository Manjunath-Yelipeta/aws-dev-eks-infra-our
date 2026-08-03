resource "aws_ssm_parameter" "bastion-iam-role-arn" {
  name  = "/${var.project}/${var.environment}/bastion-iam-role-arn"
  type  = "String"
  value = aws_iam_role.bastion.arn
  overwrite = true
}