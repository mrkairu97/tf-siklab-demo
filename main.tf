### VPC ###
resource "aws_vpc" "demo_vpc" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = "Demo_VPC"
    }
}

### IGW ###
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.demo_vpc.id
    tags = {
        Name = "Internet Gateway"
    }
}

### NAT Gateway ###
resource "aws_eip" "nat_gateway_ip" {
    vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_ip.id
  subnet_id = aws_subnet.pub_1.id
  depends_on = [aws_internet_gateway.igw]
  tags = {
      Name = "NAT Gateway"
  }
}

### VPC Subnets ###
resource "aws_subnet" "pub_1" {
  vpc_id = aws_vpc.demo_vpc.id
  cidr_block = var.pub_1_subnet_cidr_block
  availability_zone = var.pub_1_subnet_az

  tags = {
      Name = "Pub_1"
  }
}

resource "aws_subnet" "pub_2" {
  vpc_id = aws_vpc.demo_vpc.id
  cidr_block = var.pub_2_subnet_cidr_block
  availability_zone = var.pub_2_subnet_az

  tags = {
      Name = "Pub_2"
  }
}

resource "aws_subnet" "pri_1" {
  vpc_id = aws_vpc.demo_vpc.id
  cidr_block = var.pri_1_subnet_cidr_block
  availability_zone = var.pri_1_subnet_az

  tags = {
      Name = "Pri_1"
  }
}

resource "aws_subnet" "pri_2" {
  vpc_id = aws_vpc.demo_vpc.id
  cidr_block = var.pri_2_subnet_cidr_block
  availability_zone = var.pri_2_subnet_az

  tags = {
      Name = "Pri_2"
  }
}

### Route Tables ###
resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.demo_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "Public Route Table"
    }
}

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.demo_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.nat_gateway.id
    }
    tags = {
        Name = "Private Route Table"
    }
}

resource "aws_route_table_association" "pub_1" {
    subnet_id = aws_subnet.pub_1.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "pub_2" {
    subnet_id = aws_subnet.pub_2.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "pri_1" {
    subnet_id = aws_subnet.pri_1.id
    route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "pri_2" {
    subnet_id = aws_subnet.pri_2.id
    route_table_id = aws_route_table.private_route_table.id
}

### NACL for Public Subnets ###
resource "aws_network_acl" "nacl_public" {
    vpc_id = aws_vpc.demo_vpc.id
    subnet_ids = [aws_subnet.pub_1.id, aws_subnet.pub_2.id]

    egress = [
        {
            protocol = "-1"
            rule_no = 200
            action = "allow"
            cidr_block = "0.0.0.0/0"
            from_port = 0
            to_port = 0
            ipv6_cidr_block = ""
            icmp_type = 0
            icmp_code = 0
        }
    ]

    ingress = [
        {
            protocol = "tcp"
            rule_no = 100
            action = "allow"
            cidr_block = "0.0.0.0/0"
            from_port = 1024
            to_port = 65535
            ipv6_cidr_block = ""
            icmp_type = 0
            icmp_code = 0
        },
        {
            protocol = "tcp"
            rule_no = 300
            action = "allow"
            cidr_block = "0.0.0.0/0"
            from_port = 80
            to_port = 80
            ipv6_cidr_block = ""
            icmp_type = 0
            icmp_code = 0 
        },
        {
            protocol = "tcp"
            rule_no = 500
            action = "allow"
            cidr_block = "0.0.0.0/0"
            from_port = 443
            to_port = 443
            ipv6_cidr_block = ""
            icmp_type = 0
            icmp_code = 0 
        }
    ]

    tags = {
        Name = "Public NACL"
    }
}

### NACL for Private Subnets ###
resource "aws_network_acl" "nacl_private" {
    vpc_id = aws_vpc.demo_vpc.id
    subnet_ids = [aws_subnet.pri_1.id, aws_subnet.pri_2.id]

    egress = [
        {
            protocol = "-1"
            rule_no = 200
            action = "allow"
            cidr_block = "0.0.0.0/0"
            from_port = 0
            to_port = 0
            ipv6_cidr_block = ""
            icmp_type = 0
            icmp_code = 0
        }
    ]

    ingress = [
        {
            protocol = "tcp"
            rule_no = 100
            action = "allow"
            cidr_block = "0.0.0.0/0"
            from_port = 1024
            to_port = 65535
            ipv6_cidr_block = ""
            icmp_type = 0
            icmp_code = 0
        },
        {
            protocol = "tcp"
            rule_no = 300
            action = "allow"
            cidr_block = "0.0.0.0/0"
            from_port = 80
            to_port = 80
            ipv6_cidr_block = ""
            icmp_type = 0
            icmp_code = 0 
        },
        {
            protocol = "tcp"
            rule_no = 500
            action = "allow"
            cidr_block = "0.0.0.0/0"
            from_port = 443
            to_port = 443
            ipv6_cidr_block = ""
            icmp_type = 0
            icmp_code = 0 
        }
    ]

    tags = {
        Name = "Private NACL"
    }
}

### EC2 ###
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["amazon"]
}

resource "aws_iam_role" "ssm_access_role" {
  name = "ssm_ec2_access_role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
    }
}
  EOF
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ssm_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2_Instance_SSM_Profile"
  role = aws_iam_role.ssm_access_role.name
}

resource "aws_instance" "ec2_1" {
    user_data = file("install_apache.sh")
    ami = data.aws_ami.amazon_linux.id
    monitoring = true
    instance_type = "t2.micro"
    subnet_id = aws_subnet.pri_1.id
    vpc_security_group_ids = [aws_security_group.security_group_1.id]
    iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
    tags = {
        Name = "EC2_1"
    }
}

resource "aws_instance" "ec2_2" {
    user_data = file("install_apache.sh")
    ami = data.aws_ami.amazon_linux.id
    monitoring = true
    instance_type = "t2.micro"
    subnet_id = aws_subnet.pri_2.id
    vpc_security_group_ids = [aws_security_group.security_group_1.id]
    iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
    tags = {
        Name = "EC2_2"
    }
}

### Security Group ###
resource "aws_security_group" "security_group_1" {
  name        = "Security_Group_1"
  vpc_id      = aws_vpc.demo_vpc.id
  description = "Security Group for Private Subnet"

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "TCP from VPC"
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTPS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { 
      Name = "Security Group for Private Subnets" }
}

### ALB ###
resource "aws_lb_target_group" "ec2_instances" {
  name        = "tf-siklab-demo"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.demo_vpc.id
}

resource "aws_lb_target_group_attachment" "my-alb-target-group-attachment1" {
  target_group_arn = aws_lb_target_group.ec2_instances.arn
  target_id        = aws_instance.ec2_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "my-alb-target-group-attachment2" {
  target_group_arn = aws_lb_target_group.ec2_instances.arn
  target_id        = aws_instance.ec2_2.id
  port             = 80
}

resource "aws_lb" "tf_siklab_demo_alb" {
  name                       = "tf-siklab-demo-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.security_group_1.id]
  subnets                    = [aws_subnet.pub_1.id, aws_subnet.pub_2.id]
  ip_address_type            = "ipv4"
  drop_invalid_header_fields = true
  enable_deletion_protection = false #False if for testing

  tags = {
    Name = "TF_Siklab_Demo_ALB"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.tf_siklab_demo_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2_instances.arn
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_1_cpu" {

    alarm_name = var.cloudwatch_service_name_1
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "1"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "60" #seconds
    statistic = "Average"
    threshold = "70"
    alarm_description = "This metric monitors ec2 cpu utilization"
    alarm_actions = [aws_sns_topic.user_cw_alarm.arn]
    insufficient_data_actions = []

    dimensions = {
        InstanceId = aws_instance.ec2_1.id
    }
  
}

resource "aws_cloudwatch_metric_alarm" "ec2_2_cpu" {

    alarm_name = var.cloudwatch_service_name_2
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "1"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "60" #seconds
    statistic = "Average"
    threshold = "70"
    alarm_description = "This metric monitors ec2 cpu utilization"
    alarm_actions = [aws_sns_topic.user_cw_alarm.arn]
    insufficient_data_actions = []

    dimensions = {
        InstanceId = aws_instance.ec2_2.id
    }
}

resource "aws_sns_topic" "user_cw_alarm" {
  name = "user_cw_alarm"
}

resource "aws_sns_topic_subscription" "email-target" {
  topic_arn = aws_sns_topic.user_cw_alarm.arn
  protocol  = "email"
  endpoint  = var.cw_email 
}