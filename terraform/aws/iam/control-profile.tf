variable "short_name" {default = "mantl"}

resource "aws_iam_instance_profile" "control_profile" {
  name = "${var.short_name}-control-profile"
  roles = ["${aws_iam_role.control_role.name}"]
}

resource "aws_iam_role_policy" "control_policy" {
  name = "${var.short_name}-control-policy"
  role = "${aws_iam_role.control_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ec2:*"],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": ["elasticloadbalancing:*"],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": ["route53:*"],
      "Resource": ["*"]
    }
  ]
}
EOF
}

resource "aws_iam_role" "control_role" {
  name = "${var.short_name}-control-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

output "control_iam_instance_profile" {
  value = "${aws_iam_instance_profile.control_profile.name}"
}
