resource "aws_route53_zone" "default" {
  name   = "${var.environment}.${var.dns["domain_name"]}"
  vpc {
    vpc_id = "${aws_vpc.default.id}"
  }
}

resource "aws_route53_record" "default" {
  zone_id = "${aws_route53_zone.default.id}"
  name    = "_etcd-server._tcp.${local.full_environment_name}"
  type    = "SRV"
  ttl     = "1"
  records = "${formatlist("0 0 2380 %s", aws_route53_record.peers.*.name)}"
}

resource "aws_route53_record" "peers" {
  count   = "${var.cluster_size}"
  zone_id = "${aws_route53_zone.default.id}"
  name    = "${local.hosts[count.index]}"
  type    = "A"
  ttl     = "1"
  records = ["198.51.100.${count.index}"]
}
