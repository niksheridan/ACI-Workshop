resource "aci_filter" "filter" {
	tenant_dn 		= var.tenant_id
	name      		= var.filter_name
	description 	= var.filter_description
}

resource "aci_filter_entry" "entry" {
	name        = var.filter_entry_name
	filter_dn   = aci_filter.filter.id
	ether_t     = "ip"
	prot        = "tcp"
	d_from_port = var.tcp_port
	d_to_port 	= var.tcp_port
	stateful    = "yes"
}