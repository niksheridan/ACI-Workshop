### This is the authentication for ACI Provider
provider "aci" {
	username = var.username
	password = var.password
	url      = var.apic_url
	insecure = true
}

/*
	This section relates to creation of a tenant
*/

resource "aci_tenant" "workshop1_tnt" {
	name = "workshop1"
	description = "workshop1"
}

/*
	This section relates to creation of a vrf
*/

resource "aci_vrf" "workshop1_vrf1" {
	tenant_dn = aci_tenant.workshop1_tnt.id
	name      = "workshop_vrf1"
	annotation = "workshop"
}

/*
	This section relates to creation of a bridge domains and subnets
*/

### DYNAMIC CONFIGURATION NETWORKS ###
resource "aci_bridge_domain" "dynamic_services_bd1" {
	tenant_dn          = aci_tenant.workshop1_tnt.id
	relation_fv_rs_ctx = aci_vrf.workshop1_vrf1.id
	name               = "dynamic_services_bd1"
}

resource "aci_subnet" "dynamic_services_sn1" {
	parent_dn 	 = aci_bridge_domain.dynamic_services_bd1.id
  description  = "Dynamically provisioned services subnet"
	ip           = "172.31.1.1/24"
}

### FIXED CONFIGURATION NETWORKS ###
resource "aci_bridge_domain" "fixed_services_bd1" {
	tenant_dn          = aci_tenant.workshop1_tnt.id
	relation_fv_rs_ctx = aci_vrf.workshop1_vrf1.id
	name               = "fixed_services_bd1"
}

resource "aci_subnet" "fixed_services_sn1" {
	parent_dn 	 = aci_bridge_domain.fixed_services_bd1.id
  description  = "Fixed provisioned services subnet"
	ip           = "172.31.2.1/24"
}

/*
	This section relates to creation of a application profile and EPG
*/

### kubernetes clusters ###

module "cluster1" {
	source 							= "./modules/dynamic_epg"
	tenant_id						= aci_tenant.workshop1_tnt.id
	bd_id								=	aci_bridge_domain.dynamic_services_bd1.id
	ap_name							= "kubernetes"
	epg_name						= "cluster1"
	contracts_consumed	= []
	contracts_provided	= []
}

module "cluster2" {
	source 							= "./modules/dynamic_epg"
	tenant_id						= aci_tenant.workshop1_tnt.id
	bd_id								=	aci_bridge_domain.dynamic_services_bd1.id
	ap_name							= "kubernetes"
	epg_name						= "cluster2"
	contracts_consumed	= []
	contracts_provided	= []
}

module "cluster3" {
	source 							= "./modules/dynamic_epg"
	tenant_id						= aci_tenant.workshop1_tnt.id
	bd_id								=	aci_bridge_domain.dynamic_services_bd1.id
	ap_name							= "kubernetes"
	epg_name						= "cluster3"
	contracts_consumed	= []
	contracts_provided	= []
}

/*
	This section relates to creation of fixed services
*/

### database services ###
module "database1" {
	source 							= "./modules/dynamic_epg"
	tenant_id						= aci_tenant.workshop1_tnt.id
	bd_id								=	aci_bridge_domain.fixed_services_bd1.id
	ap_name							= "databases"
	epg_name						= "database1"
	contracts_consumed	= []
	contracts_provided	= []
}
module "database2" {
	source 							= "./modules/dynamic_epg"
	tenant_id						= aci_tenant.workshop1_tnt.id
	bd_id								=	aci_bridge_domain.fixed_services_bd1.id
	ap_name							= "databases"
	epg_name						= "database2"
	contracts_consumed	= []
	contracts_provided	= []
}

### gateway services ###
module "gateway1" {
	source 							= "./modules/dynamic_epg"
	tenant_id						= aci_tenant.workshop1_tnt.id
	bd_id								=	aci_bridge_domain.fixed_services_bd1.id
	ap_name							= "gateways"
	epg_name						= "api1"
	contracts_consumed	= []
	contracts_provided	= []
}
module "gateway2" {
	source 							= "./modules/dynamic_epg"
	tenant_id						= aci_tenant.workshop1_tnt.id
	bd_id								=	aci_bridge_domain.fixed_services_bd1.id
	ap_name							= "gateways"
	epg_name						= "servicebus1"
	contracts_consumed	= []
	contracts_provided	= []
}

### security services ###
module "security1" {
	source 							= "./modules/dynamic_epg"
	tenant_id						= aci_tenant.workshop1_tnt.id
	bd_id								=	aci_bridge_domain.fixed_services_bd1.id
	ap_name							= "security"
	epg_name						= "scan1"
	contracts_consumed	= []
	contracts_provided	= []
}
module "security2" {
	source 							= "./modules/dynamic_epg"
	tenant_id						= aci_tenant.workshop1_tnt.id
	bd_id								=	aci_bridge_domain.fixed_services_bd1.id
	ap_name							= "security"
	epg_name						= "apt1"
	contracts_consumed	= []
	contracts_provided	= []
}
module "security3" {
	source 							= "./modules/dynamic_epg"
	tenant_id						= aci_tenant.workshop1_tnt.id
	bd_id								=	aci_bridge_domain.fixed_services_bd1.id
	ap_name							= "security"
	epg_name						= "malware1"
	contracts_consumed	= []
	contracts_provided	= []
}



/*
	This section deals with contracts
*/

resource "aci_filter" "t2_allow_tcp" {
	tenant_dn = aci_tenant.workshop1_tnt.id
	name      = "allow_tcp"
}
resource "aci_filter" "t2_allow_icmp" {
	tenant_dn = aci_tenant.workshop1_tnt.id
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
	tenant_dn = aci_tenant.workshop1_tnt.id
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

