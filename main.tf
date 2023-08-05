provider "aws" {
  region = "us-east-1"
}

resource "aws_lambda_function" "get_ec2_metadata" {
  filename      = "getec2metadata.zip"
  function_name = "getec2metadata"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "getec2metadata.lambda_handler"
  runtime       = "python3.8"
  
  environment {
    variables = {
      INSTANCE_ID      = var.INSTANCE_ID
      S3_BUCKET_NAME  = var.S3_BUCKET_NAME
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_exec_policy" {
  name        = "lambda-exec-policy"
  description = "Policy for Lambda to access EC2 and S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["ec2:DescribeInstances"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = ["s3:PutObject"]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.S3_BUCKET_NAME}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_exec_attachment" {
  policy_arn = aws_iam_policy.lambda_exec_policy.arn
  role       = aws_iam_role.lambda_exec.name
}

data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = "getec2metadata.py"  # Change this to the name of your Python file
  output_path = "getec2metadata.zip"  # Change this to the desired ZIP file name
}
