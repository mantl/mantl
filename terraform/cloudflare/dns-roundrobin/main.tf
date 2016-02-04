variable address {} # use "*" for a wildcard domain
variable domain {}
variable subdomain { default = "lb" }
variable ttl { default = 1 } # automatic 
variable type { default = "A" }
variable ips { default = ""}
variable hostnames { default = ""}
variable count {}

#Alias all ips to address.subdomain.domain
resource "cloudflare_record" "instance" {
  count = "${var.count}" 
  domain = "${var.domain}"
  value = "${element(split(",", var.ips), count.index)}"
  name =  "${var.address}.${var.subdomain}"
  type = "${var.type}"
  ttl = "${var.ttl}"
}

