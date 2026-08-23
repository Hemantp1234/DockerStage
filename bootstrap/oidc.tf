resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a21d2c5d177a01934e135f228d4b441ee060"]
}

resource "aws_iam_role" "github_actions" {
  name = "g-a-ec2-deployer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:Hemantp1234/DockerStage:*"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "github_actions" {
  name = "terraform-gitops-access"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ec2:*"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::hemant-tf-state-dockerstage-2026"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::hemant-tf-state-dockerstage-2026/global/s3/terraform.tfstate",
          "arn:aws:s3:::hemant-tf-state-dockerstage-2026/global/s3/terraform.tfstate.tflock"
        ]
      },
      {
        Effect   = "Allow"
        Action   = "dynamodb:*"
        Resource = "arn:aws:dynamodb:ap-south-1:623170744447:table/terraform-state-locks"
      }
    ]
  })
}

output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions.arn
  description = "IAM Role ARN to use in GitHub Actions for OIDC authentication"
}