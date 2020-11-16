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
	description = "Terraform workshop"
}

resource "aci_tenant" "workshop2_tnt" {
	name = "workshop2"
	description = "Terraform workshop"
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
	This section relates to creation of application profiles and EPGs
*/

### kubernetes clusters ###

locals {
  # stamdard contracts provided
  kubernetes_provided_contracts = [
      aci_contract.kubernetes.id,
      aci_contract.databases.id
  ]
  # stamdard contracts consumed
  kubernetes_consumed_contracts = [
      aci_contract.kubernetes.id,
      aci_contract.databases.id
  ]
  
}

module "cluster1" {
	source 							= "./modules/epg"
	tenant_id						= aci_tenant.workshop1_tnt.id
	bd_id								=	aci_bridge_domain.dynamic_services_bd1.id
	ap_name							= "kubernetes"
	epg_name						= "cluster1"
	contracts_consumed	= local.kubernetes_consumed_contracts
  # setunion allows another list to be appended without duplication
	contracts_provided	= setunion(
    local.kubernetes_provided_contracts,
    [ aci_contract.security.id ]
  )
}

module "cluster2" {
	source 							= "./modules/epg"
	tenant_id						= aci_tenant.workshop1_tnt.id
	bd_id								=	aci_bridge_domain.dynamic_services_bd1.id
	ap_name							= "kubernetes"
	epg_name						= "cluster2"
	contracts_consumed	= local.kubernetes_consumed_contracts
	contracts_provided	= local.kubernetes_provided_contracts

}

module "cluster3" {
	source 							= "./modules/epg"
	tenant_id						= aci_tenant.workshop1_tnt.id
	bd_id								=	aci_bridge_domain.dynamic_services_bd1.id
	ap_name							= "kubernetes"
	epg_name						= "cluster3"
	contracts_consumed	= local.kubernetes_consumed_contracts
	contracts_provided	= local.kubernetes_provided_contracts

}

/*
	This section relates to creation of fixed services
*/

### database services ###
module "database1" {
	source 							= "./modules/epg"
	tenant_id						= aci_tenant.workshop1_tnt.id
	bd_id								=	aci_bridge_domain.fixed_services_bd1.id
	ap_name							= "databases"
	epg_name						= "database1"
	contracts_consumed	= []
	contracts_provided	= []
}
module "database2" {
	source 							= "./modules/epg"
	tenant_id						= aci_tenant.workshop1_tnt.id
	bd_id								=	aci_bridge_domain.fixed_services_bd1.id
	ap_name							= "databases"
	epg_name						= "database2"
	contracts_consumed	= []
	contracts_provided	= []
}

### gateway services ###
module "gateway1" {
	source 							= "./modules/epg"
	tenant_id						= aci_tenant.workshop1_tnt.id
	bd_id								=	aci_bridge_domain.fixed_services_bd1.id
	ap_name							= "gateways"
	epg_name						= "api1"
	contracts_consumed	= []
	contracts_provided	= []
}
module "gateway2" {
	source 							= "./modules/epg"
	tenant_id						= aci_tenant.workshop1_tnt.id
	bd_id								=	aci_bridge_domain.fixed_services_bd1.id
	ap_name							= "gateways"
	epg_name						= "servicebus1"
	contracts_consumed	= []
	contracts_provided	= []
}

### security services ###
module "security1" {
	source 							= "./modules/epg"
	tenant_id						= aci_tenant.workshop1_tnt.id
	bd_id								=	aci_bridge_domain.fixed_services_bd1.id
	ap_name							= "security"
	epg_name						= "scan1"
	contracts_consumed	= []
	contracts_provided	= []
}
module "security2" {
	source 							= "./modules/epg"
	tenant_id						= aci_tenant.workshop1_tnt.id
	bd_id								=	aci_bridge_domain.fixed_services_bd1.id
	ap_name							= "security"
	epg_name						= "apt1"
	contracts_consumed	= []
	contracts_provided	= []
}
module "security3" {
	source 							= "./modules/epg"
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

resource "aci_contract" "kubernetes" {
	tenant_dn = aci_tenant.workshop1_tnt.id
	name      = "kubernetes_services"
}

resource "aci_contract_subject" "kubernetes" {
	contract_dn                  = aci_contract.kubernetes.id
	name                         = "kubernetes"
	relation_vz_rs_subj_filt_att = [
		module.filter_web1.id,
		module.filter_database1.id
	]
}

resource "aci_contract" "databases" {
	tenant_dn = aci_tenant.workshop1_tnt.id
	name      = "database_services"
}

resource "aci_contract_subject" "databases" {
	contract_dn                  = aci_contract.databases.id
	name                         = "databases"
	relation_vz_rs_subj_filt_att = [
		module.filter_web1.id,
		module.filter_database1.id
	]
}


resource "aci_contract" "security" {
	tenant_dn = aci_tenant.workshop1_tnt.id
	name      = "security_services"
}

resource "aci_contract_subject" "security" {
	contract_dn                  = aci_contract.security.id
	name                         = "security"
	relation_vz_rs_subj_filt_att = [
		module.filter_web1.id,
		module.filter_database1.id
	]
}


resource "aci_contract" "spike" {
	tenant_dn = aci_tenant.workshop1_tnt.id
	name      = "spike_services"
}

resource "aci_contract_subject" "spike" {
	contract_dn                  = aci_contract.spike.id
	name                         = "spike"
	relation_vz_rs_subj_filt_att = [
		module.filter_web1.id,
		module.filter_database1.id
	]
}

# May be helpful to include this in a contract module 
module "contract_export1" {
	source = "./modules/contract_export"
	exported_contract_name = "spike_contract"
	description = "exported contract from workshop 1"
	tenant_source_id = aci_tenant.workshop1_tnt.id
	tenant_destination_id = aci_tenant.workshop2_tnt.id
	tenant_source_name = "workshop1"
	tenant_destination_name = "workshop2"
	contract_to_export = aci_contract.spike.name
}

/*
	This section deals with filters
*/

module "filter_web1" {
	source							=	"./modules/filter_tcp"
	tenant_id						= aci_tenant.workshop1_tnt.id
	filter_name 				= "web"
	filter_description 	= "Web filter"
	filter_entry_name 	= "http"
	tcp_port						= "80"
}

module "filter_web2" {
	source							=	"./modules/filter_tcp"
	tenant_id						= aci_tenant.workshop1_tnt.id
	filter_name 				= "web"
	filter_description 	= "Web filter"
	filter_entry_name 	= "https"
	tcp_port						= "443"
}


module "filter_database1" {
	source							=	"./modules/filter_tcp"
	tenant_id						= aci_tenant.workshop1_tnt.id
	filter_name 				= "database"
	filter_description 	= "database filter"
	filter_entry_name 	= "sql"
	tcp_port						= "1521"
}

module "filter_database2" {
	source							=	"./modules/filter_tcp"
	tenant_id						= aci_tenant.workshop1_tnt.id
	filter_name 				= "database"
	filter_description 	= "database filter"
	filter_entry_name 	= "sql2"
	tcp_port						= "1121"
}



