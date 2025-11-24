module "host_metadata" {
  source = "../modules/host_metadata"

  name     = var.name
  ipv4     = "192.168.1.10" # Example IP
  ipv6     = "2001:db8::1"  # Example IP
  location = "fsn1"         # Example location
}
