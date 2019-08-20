resource "aws_security_group" "default" {
  name        = "${local.full_environment_name}"
  description = "ASG-${var.role}"
  vpc_id      = "${aws_vpc.default.id}"

  tags = {
    Name        = "${local.full_environment_name}"
    role        = "${var.role}"
    environment = "${var.environment}"
  }

  # etcd peer + client traffic within the etcd nodes themselves
  ingress {
    from_port = 2379
    to_port   = 2380
    protocol  = "tcp"
    self      = true
  }

  # etcd client traffic from ELB
  egress {
    from_port = 2379
    to_port   = 2380
    protocol  = "tcp"
    self      = true
  }

  # etcd client traffic from the VPC
  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.default.cidr_block}"]
  }

  egress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.default.cidr_block}"]
  }
}
