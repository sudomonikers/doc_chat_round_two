resource "aws_iam_role" "lambda_role" {
  name = "lambda_opensearch_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  name       = "lambda_opensearch_policy_attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonOpenSearchServiceFullAccess" # Replace with the appropriate OpenSearch policy
  roles      = [aws_iam_role.lambda_role.name]
}

# resource "aws_lambda_function" "my_lambda" {
#   # Other configuration options for your Lambda function
#   role = aws_iam_role.lambda_role.arn
# }
