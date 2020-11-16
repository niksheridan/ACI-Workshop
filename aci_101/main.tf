### This is the authentication for ACI Provider
provider "aci" {
	username = var.username
	password = var.password
	url      = var.apic_url
	insecure = true
}

/*
	Some generic comment
*/
resource "aci_tenant" "tenant" {
	name = "workshop1"
	description = "workshop1"
}

