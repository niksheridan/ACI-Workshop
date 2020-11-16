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
resource "aci_tenant" "tenant1" {
	name = "grapefruit3"
	description = var.tenant1_grape1
	#lifecycle {
	#	prevent_destroy = true
	#}
}

resource "aci_tenant" "tenant2" {
	name = "grapefruit2"
	description = var.tenant1_grape2
	#lifecycle {
	#	prevent_destroy = true
	#}
}
resource "aci_vrf" "vrf1" {
	tenant_dn = aci_tenant.tenant1.id
	name      = "grape1_vrf1"
	annotation = "grape1"
}

resource "aci_vrf" "vrf2" {
	tenant_dn = aci_tenant.tenant2.id
	name      = "grape2_vrf1"
	annotation = "grape2"
}

resource "aci_bridge_domain" "bd1" {
	tenant_dn          = aci_tenant.tenant1.id
	relation_fv_rs_ctx = aci_vrf.vrf1.id
	name               = "grape_bd1"
}

resource "aci_subnet" "bd1_subnet1" {
	parent_dn 	 = aci_bridge_domain.bd1.id
  description  = var.bd_subnet_grape_name
	ip           = var.bd_subnet_grape_ipnet
}

resource "aci_filter" "allow_https" {
	tenant_dn = aci_tenant.tenant1.id
	name      = "allow_https"
}
resource "aci_filter" "allow_icmp" {
	tenant_dn = aci_tenant.tenant1.id
	name      = "allow_icmp"
}


resource "aci_filter_entry" "https" {
	name        = "https"
	filter_dn   = aci_filter.allow_https.id
	ether_t     = "ip"
	prot        = "tcp"
	d_from_port = "https"
	d_to_port 	= "https"
	stateful    = "yes"
}
resource "aci_filter_entry" "icmp" {
	name        = "icmp"
	filter_dn   = aci_filter.allow_icmp.id
	ether_t     = "ip"
	prot        = "icmp"
	stateful    = "yes"
}


resource "aci_contract" "web_services" {
	tenant_dn = aci_tenant.tenant1.id
	name      = "Web"
}

resource "aci_contract_subject" "Web_subject1" {
	contract_dn                  = aci_contract.web_services.id
	name                         = "web_subject1"
	relation_vz_rs_subj_filt_att = [
		aci_filter.allow_https.id,
		aci_filter.allow_icmp.id
	]
}

resource "aci_application_profile" "app1" {
	tenant_dn = aci_tenant.tenant1.id
	name      = "app1"
}
resource "aci_application_epg" "epg1" {
	application_profile_dn = aci_application_profile.app1.id
	name                   = "epg1"
	#relation_fv_rs_dom_att = ["${data.aci_vmm_domain.vds.id}"] 
	# consume a contract
	relation_fv_rs_cons    = [
		aci_contract.web_services.id
	]
}

resource "aci_application_profile" "app2" {
	tenant_dn = aci_tenant.tenant1.id
	name      = "app2"
}
resource "aci_application_epg" "epg2" {
	application_profile_dn = aci_application_profile.app2.id
	name                   = "epg2"
	relation_fv_rs_bd      = aci_bridge_domain.bd1.id
	# provide to a contract
	relation_fv_rs_prov    = [
		aci_contract.web_services.id
	]
}


resource "aci_application_profile" "app3" {
	tenant_dn = aci_tenant.tenant1.id
	name      = "app3"
}
resource "aci_application_epg" "epg3" {
	application_profile_dn = aci_application_profile.app3.id
	name                   = "epg3"
}




resource "aci_l3_outside" "l3_out1" {
	tenant_dn      = aci_tenant.tenant1.id
	description    = "Created with terraform"
	name           = "grape_l3out"
	annotation     = "tag_l3out"
	# if you want to give it a pretty name
	name_alias     = "alias_out"
	target_dscp    = "unspecified"
}


resource "aci_application_profile" "app4" {
	tenant_dn = aci_tenant.tenant2.id
	name      = "app4"
}
resource "aci_application_epg" "epg4" {
	application_profile_dn = aci_application_profile.app4.id
	name                   = "epg4"
	#relation_fv_rs_dom_att = ["${data.aci_vmm_domain.vds.id}"] 
	# consume a contract
	#relation_fv_rs_cons    = [
	#	"${aci_contract.web_services.id}"
	#]
}







resource "aci_filter" "t2_allow_tcp" {
	tenant_dn = aci_tenant.tenant2.id
	name      = "allow_tcp"
}
resource "aci_filter" "t2_allow_icmp" {
	tenant_dn = aci_tenant.tenant2.id
	name      = "allow_icmp"
}

resource "aci_filter_entry" "tcp123" {
	name        = "tcp123"
	filter_dn   = aci_filter.t2_allow_tcp.id
	ether_t     = "ip"
	prot        = "tcp"
	d_from_port = "123"
	d_to_port 	= "123"
	stateful    = "yes"
}
resource "aci_filter_entry" "t2_icmp" {
	name        = "icmp"
	filter_dn   = aci_filter.t2_allow_icmp.id
	ether_t     = "ip"
	prot        = "icmp"
	stateful    = "yes"
}

resource "aci_contract" "t2_tcp_services" {
	tenant_dn = aci_tenant.tenant2.id
	name      = "tcp_services"
}

resource "aci_contract_subject" "t2_tcp_subject" {
	contract_dn                  = aci_contract.t2_tcp_services.id
	name                         = "t2_tcp_subject"
	relation_vz_rs_subj_filt_att = [
		aci_filter.t2_allow_tcp.id,
		aci_filter.t2_allow_icmp.id
	]
}

# note the payload must align to the left with no indent
resource "aci_rest" "banana1" {
    path = "/api/mo/${aci_tenant.tenant2.id}/cif-exported_contact.json"
	depends_on = [ 
		aci_contract.web_services 
	]
    payload = <<EOF
{
  "imdata": [
		{
		"vzCPIf": {
			"attributes": {
					"annotation": "",
					"descr": "this contract is a banana",
					"dn": "uni/tn-grapefruit2/cif-exported_contact",
					"name": "exported_contact",
					"nameAlias": "",
					"ownerKey": "",
					"ownerTag": ""
				},
				"children": [
					{
						"vzRsIf": {
							"attributes": {
								"annotation": "",
								"prio": "unspecified",
								"tDn": "uni/tn-grapefruit1/brc-Web"
							}
						}
					}
				]
			}
		}
  ]
}
	EOF
}
