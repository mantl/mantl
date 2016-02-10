variable domain {}
variable subdomain { default = "mantl" }
variable ttl { default = 1 } # automatic 
variable type { default = "A" }
variable ips { default = ""}
variable hostnames { default = ""}
variable count {}

# individual records
resource "cloudflare_record" "instance" {
  count = "${var.count}" 
  domain = "${var.domain}"
  value = "${element(split(",", var.ips), count.index)}"
  name =  "${element(split(",", var.hostnames), count.index)}.${var.subdomain}"
  type = "${var.type}"
  ttl = "${var.ttl}"
}

