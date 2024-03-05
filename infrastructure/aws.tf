resource "aws_iam_user" "stitch_user" {
  name = "stitch_user"
}

data "aws_iam_policy_document" "stitch_user_s3_policy_document" {
  statement {
    effect = "Allow"
    actions = ["s3:*"]
    resources = ["arn:aws:s3:::public-bucket-team-stitch/*"]
  }
}

resource "aws_iam_user_policy" "stitch_user_s3_policy" {
  name = "stitch_user_s3_policy"
  user = aws_iam_user.stitch_user.name
  policy = data.aws_iam_policy_document.stitch_user_s3_policy_document.json
}

resource "aws_iam_access_key" "stitch_access_key" {
  user = aws_iam_user.stitch_user.name
}

resource "aws_s3_bucket" "public_bucket" {
  bucket = var.s3_bucket_name
  acl = "public-read-write"

  tags = {
    Name = var.s3_bucket_name
    owner = var.owner
    expire = var.expire
    purpose = var.purpose
    project = var.project
  }
}

resource "aws_s3_bucket_cors_configuration" "allow_cors" {
  bucket = aws_s3_bucket.public_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET"]
    allowed_origins = ["*"]
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.public_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.transferFunction.arn
    events = ["s3:ObjectCreated:*"]
  }
}

data "aws_iam_policy_document" "lambda_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_role.json

  inline_policy {
    name = "ec2_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Action = [
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeInstances",
          "ec2:AttachNetworkInterface"
        ]
        Effect = "Allow"
        Resource = "*"
      }]
    })
  }
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id = "AllowExecutionFromS3Bucket"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.transferFunction.arn
  principal = "s3.amazonaws.com"
  source_arn = aws_s3_bucket.public_bucket.arn
}

data "archive_file" "transferFunction" {
  type = "zip"
  source_dir = "${path.module}/../lambda/transferFunction/"
  output_path = "transferFunction.zip"
}

resource "aws_lambda_function" "transferFunction" {
  filename = "${path.module}/transferFunction.zip"
  function_name = "transferFunction"
  role = aws_iam_role.iam_for_lambda.arn
  handler = "main.handler"
  runtime = "python3.12"
  source_code_hash = data.archive_file.transferFunction.output_base64sha256

  depends_on = [data.archive_file.transferFunction]

  vpc_config {
    subnet_ids = [aws_subnet.private_subnet.id]
    security_group_ids = [aws_security_group.default.id]
  }

  environment {
    variables = {
      MONGO_URL = mongodbatlas_cluster.cluster.connection_strings.0.standard_srv
      MONGO_USER = var.atlas_user_name
      MONGO_PASSWORD = var.atlas_password
      MONGO_DB = var.db_name
      MONGO_COLL = var.coll_name
    }
  }
}

resource "aws_cloudwatch_log_group" "transferFunctionLogs" {
  name = "/aws/lambda/${aws_lambda_function.transferFunction.function_name}"
  retention_in_days = 14
}

data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}
