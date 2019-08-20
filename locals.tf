locals {
  full_environment_name = "${var.role}.${var.region}.i.${var.environment}.${var.dns["domain_name"]}"
  hosts                 = [for i in range(var.cluster_size) : "peer-${i}.${local.full_environment_name}"]
  key_algorithm         = "RSA"
}
