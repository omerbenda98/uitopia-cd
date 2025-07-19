resource "aws_iam_role" "external_dns" {
  name = "${var.cluster_name}-external-dns-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.cluster.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.cluster.url, "https://", "")}:sub": "system:serviceaccount:external-dns:external-dns"
            "${replace(aws_iam_openid_connect_provider.cluster.url, "https://", "")}:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# External-DNS IAM Policy
resource "aws_iam_policy" "external_dns" {
  name = "${var.cluster_name}-external-dns-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets"
        ]
        Resource = "arn:aws:route53:::hostedzone/*"
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:GetChange"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}
resource "aws_iam_role_policy_attachment" "external_dns" {
  policy_arn = aws_iam_policy.external_dns.arn
  role       = aws_iam_role.external_dns.name
}






# Install external-dns using Helm
resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = "external-dns"
  namespace  = "external-dns"
  version    = var.external_dns_version
  create_namespace = true

  set = concat([
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = "external-dns"
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.external_dns.arn
    },
    {
      name  = "provider"
      value = "aws"
    },
    {
      name  = "aws.region"
      value = var.aws_region
    },
    {
      name  = "txtOwnerId"
      value = var.cluster_name
    },
    {
      name  = "sources[0]"
      value = "service"
    },
    {
      name  = "sources[1]"
      value = "ingress"
    },
    {
      name  = "logLevel"
      value = "info"
    },
  ], var.external_dns_domain_filters != null ? [
    for i, domain in var.external_dns_domain_filters : {
      name  = "domainFilters[${i}]"
      value = domain
    }
  ] : [])

  depends_on = [
    aws_eks_node_group.node_group,
    aws_iam_role_policy_attachment.external_dns,
    helm_release.ingress_nginx
  ]

  timeout = 300
}

