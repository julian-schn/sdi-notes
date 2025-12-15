# Exercise 22 - Creating DNS Records
# Creates A and CNAME records with validation

data "hetznerdns_zone" "main" {
  name = var.dns_zone
}

# 1. Canonical A Record (workhorse.gxy...)
resource "hetznerdns_record" "workhorse" {
  zone_id = data.hetznerdns_zone.main.id
  name    = var.server_name
  value   = var.server_ip
  type    = "A"
  ttl     = 3600
}

# 2. Root A Record (gxy...)
resource "hetznerdns_record" "root" {
  zone_id = data.hetznerdns_zone.main.id
  name    = "@" 
  value   = var.server_ip
  type    = "A"
  ttl     = 3600
}

# 3. Aliases (CNAMEs pointing to workhorse)
resource "hetznerdns_record" "aliases" {
  count = length(var.server_aliases)

  zone_id = data.hetznerdns_zone.main.id
  name    = var.server_aliases[count.index]
  value   = "${var.server_name}.${var.dns_zone}."
  type    = "CNAME"
  ttl     = 3600
}
