resource "tls_private_key" "peer" {
  count     = "${var.cluster_size}"
  algorithm = "${local.key_algorithm}"
}

resource "tls_cert_request" "peer" {
  count           = "${var.cluster_size}"
  key_algorithm   = "${tls_private_key.peer[count.index].algorithm}"
  private_key_pem = "${tls_private_key.peer[count.index].private_key_pem}"

  subject {
    common_name = "etcd"
  }
  dns_names = ["${local.hosts[count.index]}", "localhost"]
  ip_addresses = ["127.0.0.1"]
}

resource "tls_locally_signed_cert" "peer" {
  count            = "${var.cluster_size}"
  cert_request_pem = "${tls_cert_request.peer[count.index].cert_request_pem}"

  ca_key_algorithm   = "${tls_private_key.ca.algorithm}"
  ca_private_key_pem = "${tls_private_key.ca.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.ca.cert_pem}"

  validity_period_hours = 17520
  early_renewal_hours   = 8760

  allowed_uses = ["client_auth", "digital_signature", "key_encipherment", "server_auth"]
}

resource "aws_s3_bucket_object" "peer_crt" {
  count   = "${var.cluster_size}"
  bucket  = "${aws_s3_bucket.files.id}"
  key     = "certs/${local.hosts[count.index]}/peer.crt"
  content = "${tls_locally_signed_cert.peer[count.index].cert_pem}"
  etag    = "${md5(tls_locally_signed_cert.peer[count.index].cert_pem)}"
}

resource "aws_s3_bucket_object" "peer_key" {
  count   = "${var.cluster_size}"
  bucket  = "${aws_s3_bucket.files.id}"
  key     = "certs/${local.hosts[count.index]}/peer.key"
  content = "${tls_private_key.peer[count.index].private_key_pem}"
  etag    = "${md5(tls_private_key.peer[count.index].private_key_pem)}"
}
