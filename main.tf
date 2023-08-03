provider "aws" {
  region = "us-east-1"  # Replace with your desired region
}

resource "aws_lambda_function" "get_ec2_metadata" {
  filename      = data.archive_file.lambda_function.output_path
  function_name = "getec2metadata"  # Replace with the desired Lambda function name
  role          = aws_iam_role.lambda_execution.arn
  handler       = "getec2metadata.lambda_handler"  # Make sure this handler name matches the Python function name in the code

  runtime = "python3.8"  # Replace with the desired Python runtime version

  source_code_hash = filebase64sha256(data.archive_file.lambda_function.output_path)

  environment {
    variables = {
      INSTANCE_ID      = var.instance_id
      S3_BUCKET_NAME   = var.s3_bucket_name
    }
  }
}

data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = "getec2metadata.py"  # Replace with the actual name of your Python function file
  output_path = "${path.module}/getec2metadata.zip"
}

resource "aws_iam_role" "lambda_execution" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_execution_attach" {
  name       = "lambda_execution_attach"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  roles      = [aws_iam_role.lambda_execution.name]
}
