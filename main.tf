provider "aws" {
  region = var.aws_region

}
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}
resource "aws_subnet" "sub" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr
  tags = {
    Name = var.subnet_name
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = var.igw_name
  }

}
resource "aws_default_route_table" "non" {
  default_route_table_id = aws_vpc.main.default_route_table_id

}
resource "aws_route_table_association" "rtb" {
  route_table_id = aws_vpc.main.default_route_table_id
  subnet_id      = aws_subnet.sub.id

}
resource "aws_security_group" "sss" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

  }
  tags = {
    Name = var.group_name
  }

}

resource "aws_iam_role" "r-1" {
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "persmission"
  }
}
resource "aws_iam_role_policy_attachment" "example" {
  role       = aws_iam_role.r-1.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.r-1.name
}
resource "aws_key_pair" "ram" {
  key_name   = "ram"
  public_key = file("${path.module}/aws-key.pem")

  tags = {
    Name = "ram"
  }


}
resource "aws_instance" "server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.sub.id
  vpc_security_group_ids = [aws_security_group.sss.id]
  key_name               = aws_key_pair.ram.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

}
resource "aws_sns_topic" "sns" {
  tags = {
    Name = "sns"
  }

}
resource "aws_sns_topic_subscription" "asts" {
  topic_arn = aws_sns_topic.sns.arn
  protocol  = "email"
  endpoint  = var.sns_endpoint

}
resource "aws_cloudwatch_metric_alarm" "foobar" {
  alarm_name                = "terraform-test-foobar5"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = var.metric_name
  namespace                 = "AWS/EC2"
  period                    = 120
  statistic                 = "Average"
  threshold                 = var.threshold_no
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = [aws_sns_topic.sns.arn]
  alarm_actions             = [aws_sns_topic.sns.arn]
  ok_actions                = [aws_sns_topic.sns.arn]
  dimensions = {
    aws_instance_id = aws_instance.server.id
  }
}