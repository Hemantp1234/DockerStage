# 1. Register GitHub as an OIDC Identity Provider in AWS

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"] 
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a21d2c5d177a01934e135f228d4b441ee060"]
}

# 2. Create IAM Role with Repo-Scoped Trust Policy
resource "aws_iam_role" "github_actions" {
  name = "g-a-ec2-deployer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
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
            # Replace with your GitHub Username and Repo Name
            "token.actions.githubusercontent.com:sub" = "repo:Hemantp1234/DockerStage:*"
          }
        }
      }
    ]
  })
}

# 3. Attach EC2 Policy to the IAM Role
resource "aws_iam_role_policy_attachment" "github_actions_ec2_policy" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# 4. Output the Role ARN
output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions.arn
  description = "IAM Role ARN to use in GitHub Actions for OIDC authentication"
}