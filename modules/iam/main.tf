data "aws_caller_identity" "current" {}

resource "aws_iam_role" "ansible" {
  name        = "ansible-controller-role"
  description = "IAM role for Ansible controller EC2 instance"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "read_oauth_parameters" {
  name        = "ansible-read-oauth-parameters"
  description = "Allows Ansible controller to read OAuth2 Proxy secrets from SSM"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ReadOAuthParameters"
        Effect = "Allow"

        Action = [
          "ssm:GetParameter"
        ]

        Resource = [
          "arn:aws:ssm:eu-central-1:${data.aws_caller_identity.current.account_id}:parameter/task4/oauth2/github-client-secret",
          "arn:aws:ssm:eu-central-1:${data.aws_caller_identity.current.account_id}:parameter/task4/oauth2/cookie-secret"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ansible" {
  role       = aws_iam_role.ansible.name
  policy_arn = aws_iam_policy.read_oauth_parameters.arn
}

resource "aws_iam_instance_profile" "ansible" {
  name = "ansible-controller-profile"
  role = aws_iam_role.ansible.name
}