# Metrics Server Add-on
resource "aws_eks_addon" "metrics_server" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "metrics-server"
  resolve_conflicts_on_create = "OVERWRITE"
}

# Cert Manager Add-on
resource "aws_eks_addon" "cert_manager" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "cert-manager"
  resolve_conflicts_on_create = "OVERWRITE"
}

# AWS Load Balancer Controller with ECR image
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.8.1"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws_load_balancer_controller.arn
  }

  set {
    name  = "image.repository"
    value = "public.ecr.aws/eks/aws-load-balancer-controller"
  }

  set {
    name  = "image.tag"
    value = "v2.13.3"
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "region"
    value = "ap-southeast-1"
  }

  depends_on = [
    aws_eks_node_group.main,
    aws_iam_role_policy_attachment.aws_load_balancer_controller_attach
  ]
}