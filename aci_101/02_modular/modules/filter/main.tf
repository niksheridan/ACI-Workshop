

resource "aci_filter" "t2_allow_tcp" {
	tenant_dn = aci_tenant.tenant2.id
	name      = "allow_tcp"
}

resource "aci_filter_entry" "entry" {
	name        = "tcp123"
	filter_dn   = aci_filter.t2_allow_tcp.id
	ether_t     = "ip"
	prot        = "tcp"
	d_from_port = var.tcpport
	d_to_port 	= var.tcpport
	stateful    = "yes"
}