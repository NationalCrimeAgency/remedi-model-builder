data "aws_s3_bucket" "model_bucket" {
  bucket = "${var.model_bucket}"
}

data "aws_s3_bucket" "gold_bucket" {
  bucket = "${var.gold_bucket}"
}

data "aws_s3_bucket" "user_contribution_bucket" {
  bucket = "${var.user_contribution_bucket}"
}

data "template_file" "model-builder" {
  template = "${file("${path.module}/templates/run-training.tpl")}"

  count = "${length(var.languages)}"

  vars {
    LANGUAGE = "${element(var.languages, count.index)}"
    LANGUAGE_NAME = "${element(var.language_names, count.index)}"
    MODEL_BUCKET_NAME = "${var.model_bucket}"
    GOLD_BUCKET_NAME = "${var.gold_bucket}"
    USER_CONTRIBUTION_BUCKET_NAME = "${var.user_contribution_bucket}"
  }
}

resource "aws_instance" "main" {
  ami                   = "${var.ami_id}"
  subnet_id             = "${var.subnet_id}"
  instance_type         = "m5.4xlarge"
  key_name              = "${var.key_name}"
  vpc_security_group_ids= ["${aws_security_group.model-builder.id}"]
  iam_instance_profile  = "${aws_iam_instance_profile.model-builder-profile.id}"

  count = "${length(var.languages)}"

  instance_initiated_shutdown_behavior = "terminate"

  root_block_device {
    volume_size = "${var.disk_size}"
  }

  depends_on = ["aws_iam_role.model-builder"]

  tags = "${merge(map("Name", "model-builder", "Language", element(var.languages, count.index)), "${var.tags}")}"
  user_data = "${element(data.template_file.model-builder.*.rendered, count.index)}"

}

## Security and IAM

resource "aws_security_group" "model-builder" {
  name = "model-builder"
  vpc_id = "${var.vpc_id}"

  # SSH from den
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.cidrs}"]
  }
  #Needed for the role to work
  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #Needed for updates
  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "model-builder"
  }
}

resource "aws_iam_instance_profile" "model-builder-profile" {
  name  = "model-builder-profile"
  role = "${aws_iam_role.model-builder.name}"
}

resource "aws_iam_role" "model-builder" {
  name = "model-builder"
  assume_role_policy = "${data.aws_iam_policy_document.assume-policy.json}"
}

data "aws_iam_policy_document" "assume-policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    effect = "Allow"
  }
}

resource "aws_iam_role_policy" "role-policy" {
  name     = "model-builder-policy"
  role     = "${aws_iam_role.model-builder.id}"
  policy   = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "WriteModels",
      "Effect": "Allow",
      "Action": [
        "s3:List*",
        "s3:DeleteObject",
        "s3:PutObject"
      ],
      "Resource": [
        "${data.aws_s3_bucket.model_bucket.arn}",
        "${data.aws_s3_bucket.model_bucket.arn}/*"
      ]
    },
    {
      "Sid": "GetTranslations",
      "Effect": "Allow",
      "Action": ["s3:GetObject*","s3:List*"],
      "Resource": [
        "${data.aws_s3_bucket.gold_bucket.arn}",
        "${data.aws_s3_bucket.gold_bucket.arn}/*",
        "${data.aws_s3_bucket.user_contribution_bucket.arn}",
        "${data.aws_s3_bucket.user_contribution_bucket.arn}/*"
      ]
    },
    {
      "Sid": "PublishLogs",
      "Effect": "Allow",
      "Action": [
        "cloudwatch:PutMetricData",
        "ec2:DescribeTags",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams",
        "logs:DescribeLogGroups",
        "logs:CreateLogStream"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "kms" {
  role       = "${aws_iam_role.model-builder.name}"
  policy_arn = "${var.kms_policy_arn}"
}

resource "aws_cloudwatch_log_group" "model-builder-logs" {
  name        = "/remedi/model-builder/output"
  kms_key_id  = "${var.kms_key_arn}"
}