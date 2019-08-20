resource "tls_private_key" "ca" {
  algorithm = "${local.key_algorithm}"
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm   = "${local.key_algorithm}"
  private_key_pem = "${tls_private_key.ca.private_key_pem}"

  validity_period_hours = 26280
  early_renewal_hours   = 8760

  is_ca_certificate = true

  allowed_uses = ["key_encipherment", "digital_signature", "crl_signing"]

  subject {
    common_name = "etcd-ca"
  }
}

resource "aws_s3_bucket_object" "ca_crt" {
  bucket  = "${aws_s3_bucket.files.id}"
  key     = "certs/ca.crt"
  content = "${tls_self_signed_cert.ca.cert_pem}"
  etag    = "${md5(tls_self_signed_cert.ca.cert_pem)}"
}
