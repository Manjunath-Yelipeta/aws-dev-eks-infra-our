locals {
    eks_cluster_name = data.aws_ssm_parameter.eks_cluster_name.value
    bastion-iam-role-arn = data.aws_ssm_parameter.bastion-iam-role-arn.value
}