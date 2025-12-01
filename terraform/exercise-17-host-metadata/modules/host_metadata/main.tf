resource "local_file" "hostdata" {
  content = templatefile(
    "${path.module}/tpl/hostdata.json", {
      ip4      = var.ipv4
      ip6      = var.ipv6
      location = var.location
  })
  filename = "Gen/${var.name}.json"
}
