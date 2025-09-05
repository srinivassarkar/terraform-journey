variable "servers" {
  type = map(string)
  default = {
    web   = "Web Server Config"
    db    = "Database Server Config"  
    cache = "Cache Server Config"
  }
}

resource "local_file" "server_configs" {
  for_each = var.servers
  content  = each.value
  filename = "${each.key}-config.txt"
}