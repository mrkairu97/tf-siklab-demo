output "EC2_1_Instance" {
    value = aws_instance.ec2_1.id
}

output "EC2_2_Instance" {
    value = aws_instance.ec2_2.id
}

output "ALB_Link" {
    value = "http://${aws_lb.tf_siklab_demo_alb.dns_name}"
}

output "VPC_ID" {
    value = "${aws_vpc.demo_vpc.id}"
}