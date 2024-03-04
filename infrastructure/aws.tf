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

data "aws_iam_policy_document" "assume_role" {
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
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
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
  source_file = "${path.module}/../lambda/transferFunction/main.py"
  output_path = "transferFunction.zip"
}

resource "aws_lambda_function" "transferFunction" {
  filename = "${path.module}/transferFunction.zip"
  function_name = "transferFunction"
  role = aws_iam_role.iam_for_lambda.arn
  handler = "main.handler"
  runtime = "python3.11"
  source_code_hash = data.archive_file.transferFunction.output_base64sha256

  depends_on = [data.archive_file.transferFunction]
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

# resource "aws_s3_bucket_ownership_controls" "public_bucket_access" {
  # bucket = aws_s3_bucket.public_bucket.id
#
  # rule {
    # object_ownership = "BucketOwnerPreferred"
  # }
# }
#
# resource "aws_s3_bucket_public_access_block" "public_access_block" {
  # bucket = aws_s3_bucket.public_bucket.id
#
  # block_public_acls = false
  # block_public_policy = false
  # ignore_public_acls = false
  # restrict_public_buckets = false
# }

# [>==== The VPC ======<]
# resource "aws_vpc" "vpc" {
  # cidr_block           = "${var.vpc_cidr}"
  # enable_dns_hostnames = true
  # enable_dns_support   = true
#
  # tags = {
    # owner = "${var.owner}"
    # expire-on = "${var.expire}"
    # purpose = "${var.purpose}"
    # project = "${var.project}"
    # Name = "${var.project}"
  # }
# }
#
# [>==== Subnets ======<]
# [> Internet gateway for the public subnet <]
# resource "aws_internet_gateway" "ig" {
  # vpc_id = "${aws_vpc.vpc.id}"
#
  # tags = {
    # owner = "${var.owner}"
    # expire-on = "${var.expire}"
    # purpose = "${var.purpose}"
    # project = "${var.project}"
  # }
# }
#
# [> Public subnet <]
# resource "aws_subnet" "public_subnet" {
  # vpc_id                  = aws_vpc.vpc.id
  # cidr_block              = var.public_subnet_cidr
  # availability_zone       = var.availability_zone
  # map_public_ip_on_launch = true
#
  # tags = {
    # owner = "${var.owner}"
    # expire-on = "${var.expire}"
    # purpose = "${var.purpose}"
    # project = "${var.project}"
    # Name = "${var.project}-sn-pblc"
  # }
# }
#
# [> Routing table for public subnet <]
# resource "aws_default_route_table" "public" {
  # default_route_table_id = aws_vpc.vpc.default_route_table_id
#
  # tags = {
    # owner = "${var.owner}"
    # expire-on = "${var.expire}"
    # purpose = "${var.purpose}"
    # project = "${var.project}"
    # Name = "${var.project}-rtb-pblc"
  # }
# }
#
# [> Routing table for public subnet <]
# resource "aws_route_table" "private" {
  # vpc_id = aws_vpc.vpc.id
#
  # tags = {
    # owner = "${var.owner}"
    # expire-on = "${var.expire}"
    # purpose = "${var.purpose}"
    # project = "${var.project}"
    # Name = "${var.project}-rtb-prvt"
  # }
# }
#
# resource "aws_route" "public_internet_gateway" {
  # route_table_id         = "${aws_default_route_table.public.id}"
  # destination_cidr_block = "0.0.0.0/0"
  # gateway_id             = "${aws_internet_gateway.ig.id}"
# }
#
# [> Route table associations <]
# resource "aws_main_route_table_association" "public" {
  # vpc_id = "${aws_vpc.vpc.id}"
  # route_table_id = "${aws_default_route_table.public.id}"
# }
#
# [>==== VPC's Default Security Group ======<]
# resource "aws_security_group" "default" {
  # name        = "${var.project}-default-sg"
  # description = "Default security group to allow inbound/outbound from the VPC"
  # vpc_id      = "${aws_vpc.vpc.id}"
  # depends_on  = [aws_vpc.vpc]
#
  # ingress = [
    # {
      # description      = "All Ports/Protocols"
      # from_port        = 0
      # to_port          = 0
      # protocol         = "-1"
      # cidr_blocks      = ["0.0.0.0/0"]
      # ipv6_cidr_blocks = ["::/0"]
      # prefix_list_ids  = null
      # security_groups  = null
      # self             = null
    # }
  # ]
#
  # egress = [
    # {
      # description      = "All Ports/Protocols"
      # from_port        = 0
      # to_port          = 0
      # protocol         = "-1"
      # cidr_blocks      = ["0.0.0.0/0"]
      # ipv6_cidr_blocks = ["::/0"]
      # prefix_list_ids  = null
      # security_groups  = null
      # self             = null
    # }
  # ]
#
  # tags = {
    # owner = "${var.owner}"
    # expire-on = "${var.expire}"
    # purpose = "${var.purpose}"
    # project = "${var.project}"
  # }
# }
# data "aws_ami" "amazon_linux" {
  # most_recent = true
#
  # filter {
    # name = "name"
    # values = ["amazon*"]
  # }
#
  # filter {
    # name = "architecture"
    # values = ["x86_64"]
  # }
# }
#
# resource "aws_key_pair" "key_pair" {
  # key_name = var.key_name
  # public_key = file(var.key_path)
# }
#
# resource "aws_instance" "public_instance" {
  # ami                    = data.aws_ami.amazon_linux.image_id
  # instance_type          = "t3.micro"
  # vpc_security_group_ids = [aws_security_group.default.id]
  # key_name               = aws_key_pair.key_pair.key_name
#
  # subnet_id      = "${element(aws_subnet.public_subnet.*.id, 0)}"
#
  # user_data = file("./deploy.sh")
#
  # tags = {
    # owner = "${var.owner}"
    # expire-on = "${var.expire}"
    # purpose = "${var.purpose}"
    # project = "${var.project}"
    # Name = "${var.project}-instance"
  # }
# }
