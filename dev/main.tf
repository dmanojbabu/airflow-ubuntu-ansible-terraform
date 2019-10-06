provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

resource "aws_key_pair" "de-fip" {
  key_name   = "de-fip-key${var.deployment_suffix}"
  public_key = "${var.pub_key}"
}

resource "aws_instance" "de-fip" {
  ami               = "${var.ami}"
  instance_type     = "t2.micro"
  monitoring        = true
  availability_zone = "${var.aws_az}"
  key_name          = "${aws_key_pair.de-fip.key_name}"
  tags {
    Name = "de-fip${var.deployment_suffix}"
  }
  security_groups = ["${aws_security_group.de-fip.name}"]
}


resource "aws_security_group_rule" "main_egress" {
  type            = "egress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.de-fip.id}"
}

resource "aws_security_group_rule" "ssh" {
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.de-fip.id}"
}

resource "aws_security_group_rule" "airflow-web" {
  type            = "ingress"
  from_port       = 8080
  to_port         = 8080
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.de-fip.id}"
}

resource "aws_security_group" "de-fip" {
  name = "de-fip-sg${var.deployment_suffix}"
  description = "de-fip${var.deployment_suffix} security groups"
}

resource "aws_eip" "de-fip" {
  instance = "${aws_instance.de-fip.id}"
}

output "ip" {
   value = "${aws_eip.de-fip.public_ip}"
}
