resource "aci_filter" "filter" {
	tenant_dn = aci_tenant.tenant2.id
	name      = var.filter_name
}

resource "aci_filter_entry" "entry" {
	name        = var.filter_entry_name
	filter_dn   = aci_filter.filter.id
	ether_t     = "ip"
	prot        = "tcp"
	d_from_port = var.tcpport
	d_to_port 	= var.tcpport
	stateful    = "yes"
}