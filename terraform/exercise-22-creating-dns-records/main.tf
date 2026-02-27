# Exercise 22 - Creating DNS Records
# Creates A and CNAME records with validation

locals {
  alias_matches_server_name = contains(var.server_aliases, var.server_name)
  dns_zone_with_dot         = "${var.dns_zone}."
}

resource "dns_a_record_set" "workhorse" {
  zone      = local.dns_zone_with_dot
  name      = var.server_name
  addresses = [var.server_ip]
  ttl       = 10

  lifecycle {
    precondition {
      condition     = !local.alias_matches_server_name
      error_message = "Server alias name '${var.server_name}' matches server's canonical name. Aliases must be different from the server name."
    }
  }
}

# AI-assisted: nsupdate with HMAC-SHA512 auth, includes destroy provisioner
resource "null_resource" "root_record" {
  triggers = {
    server_ip  = var.server_ip
    zone       = var.dns_zone
    project    = var.project
    dns_secret = var.dns_secret
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "server ns1.sdi.hdm-stuttgart.cloud
      update delete ${var.dns_zone}. A
      update add ${var.dns_zone}. 10 A ${var.server_ip}
      send" | nsupdate -y "hmac-sha512:${var.project}.key:${var.dns_secret}"
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "server ns1.sdi.hdm-stuttgart.cloud
      update delete ${self.triggers.zone}. A
      send" | nsupdate -y "hmac-sha512:${self.triggers.project}.key:${self.triggers.dns_secret}" || true
    EOT
  }
}

resource "time_sleep" "wait_after_a_record" {
  create_duration = "2s"
  depends_on      = [dns_a_record_set.workhorse]
}

resource "dns_cname_record" "aliases" {
  for_each = toset(var.server_aliases)

  zone  = local.dns_zone_with_dot
  name  = each.value
  cname = "${var.server_name}.${var.dns_zone}."
  ttl   = 10

  depends_on = [time_sleep.wait_after_a_record]
}
