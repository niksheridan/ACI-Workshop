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

resource "aci_tenant" "workshop0_tnt" {
  name        = "a_workshop0"
  description = "Terraform workshop"
}


resource "aci_tenant" "workshop1_tnt" {
  name        = "a_workshop1"
  description = "Terraform workshop"
}

resource "aci_tenant" "workshop2_tnt" {
  name        = "a_workshop2"
  description = "Terraform workshop"
}

/*
	This section relates to creation of a vrf
*/

resource "aci_vrf" "workshop1_vrf0" {
  tenant_dn  = aci_tenant.workshop0_tnt.id
  name       = "workshop_vrf0"
  annotation = "workshop"
}

resource "aci_vrf" "workshop1_vrf1" {
  tenant_dn  = aci_tenant.workshop1_tnt.id
  name       = "workshop_vrf1"
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
  parent_dn   = aci_bridge_domain.dynamic_services_bd1.id
  description = "Dynamically provisioned services subnet"
  ip          = "172.31.1.1/24"
  scope       = ["shared", "public"]
}

resource "aci_bridge_domain" "dynamic_services_bd0" {
  tenant_dn          = aci_tenant.workshop0_tnt.id
  relation_fv_rs_ctx = aci_vrf.workshop1_vrf0.id
  name               = "dynamic_services_bd0"
}

resource "aci_subnet" "dynamic_services_sn0" {
  parent_dn   = aci_bridge_domain.dynamic_services_bd0.id
  description = "Dynamically provisioned services subnet"
  ip          = "172.31.0.1/24"
  scope       = ["shared", "public"]
}

### FIXED CONFIGURATION NETWORKS ###
resource "aci_bridge_domain" "fixed_services_bd1" {
  tenant_dn          = aci_tenant.workshop1_tnt.id
  relation_fv_rs_ctx = aci_vrf.workshop1_vrf1.id
  name               = "fixed_services_bd1"
}

resource "aci_subnet" "fixed_services_sn1" {
  parent_dn   = aci_bridge_domain.fixed_services_bd1.id
  description = "Fixed provisioned services subnet"
  ip          = "172.31.2.1/24"
  scope       = ["shared", "public"]
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
  source             = "./modules/epg"
  tenant_id          = aci_tenant.workshop1_tnt.id
  bd_id              = aci_bridge_domain.dynamic_services_bd1.id
  ap_name            = "kubernetes"
  epg_name           = "cluster1"
  contracts_consumed = local.kubernetes_consumed_contracts
  # setunion allows another list to be appended without duplication
  contracts_provided = setunion(
    local.kubernetes_provided_contracts,
    [aci_contract.security.id]
  )
}

module "cluster2" {
  source             = "./modules/epg"
  tenant_id          = aci_tenant.workshop1_tnt.id
  bd_id              = aci_bridge_domain.dynamic_services_bd1.id
  ap_name            = "kubernetes"
  epg_name           = "cluster2"
  contracts_consumed = local.kubernetes_consumed_contracts
  contracts_provided = local.kubernetes_provided_contracts

}

module "cluster3" {
  source             = "./modules/epg"
  tenant_id          = aci_tenant.workshop1_tnt.id
  bd_id              = aci_bridge_domain.dynamic_services_bd1.id
  ap_name            = "kubernetes"
  epg_name           = "cluster3"
  contracts_consumed = local.kubernetes_consumed_contracts
  contracts_provided = local.kubernetes_provided_contracts

}

/*
	This section relates to creation of fixed services
*/
### Business App ###

module "biz_presentation1" {
  source             = "./modules/epg"
  tenant_id          = aci_tenant.workshop1_tnt.id
  bd_id              = aci_bridge_domain.fixed_services_bd1.id
  ap_name            = "biz-stack1"
  epg_name           = "biz-presentation1"
  contracts_consumed = [aci_contract.spike.id]
  contracts_provided = []
}

module "biz_application1" {
  source             = "./modules/epg"
  tenant_id          = aci_tenant.workshop1_tnt.id
  bd_id              = aci_bridge_domain.fixed_services_bd1.id
  ap_name            = "biz-stack1"
  epg_name           = "biz-application1"
  contracts_consumed = [aci_contract.spike.id]
  contracts_provided = []
}

module "biz_database2" {
  source             = "./modules/epg"
  tenant_id          = aci_tenant.workshop1_tnt.id
  bd_id              = aci_bridge_domain.fixed_services_bd1.id
  ap_name            = "biz-stack1"
  epg_name           = "biz-database1"
  contracts_consumed = [aci_contract.spike.id]
  contracts_provided = []
}


### database services ###
module "database1" {
  source             = "./modules/epg"
  tenant_id          = aci_tenant.workshop1_tnt.id
  bd_id              = aci_bridge_domain.fixed_services_bd1.id
  ap_name            = "databases"
  epg_name           = "database1"
  contracts_consumed = [aci_contract.spike.id]
  contracts_provided = []
}
module "database2" {
  source             = "./modules/epg"
  tenant_id          = aci_tenant.workshop1_tnt.id
  bd_id              = aci_bridge_domain.fixed_services_bd1.id
  ap_name            = "databases"
  epg_name           = "database2"
  contracts_consumed = [aci_contract.spike.id]
  contracts_provided = []
}

### gateway services ###
module "gateway1" {
  source             = "./modules/epg"
  tenant_id          = aci_tenant.workshop1_tnt.id
  bd_id              = aci_bridge_domain.fixed_services_bd1.id
  ap_name            = "gateways"
  epg_name           = "api1"
  contracts_consumed = []
  contracts_provided = [aci_contract.spike.id]
}
module "gateway2" {
  source             = "./modules/epg"
  tenant_id          = aci_tenant.workshop1_tnt.id
  bd_id              = aci_bridge_domain.fixed_services_bd1.id
  ap_name            = "gateways"
  epg_name           = "servicebus1"
  contracts_consumed = [aci_contract.spike.id]
  contracts_provided = []
}

### security services ###
module "security1" {
  source             = "./modules/epg"
  tenant_id          = aci_tenant.workshop1_tnt.id
  bd_id              = aci_bridge_domain.fixed_services_bd1.id
  ap_name            = "security"
  epg_name           = "scan1"
  contracts_consumed = [aci_contract.spike.id]
  contracts_provided = []
}
module "security2" {
  source             = "./modules/epg"
  tenant_id          = aci_tenant.workshop1_tnt.id
  bd_id              = aci_bridge_domain.fixed_services_bd1.id
  ap_name            = "security"
  epg_name           = "apt1"
  contracts_consumed = [aci_contract.spike.id]
  contracts_provided = []
}
module "security3" {
  source             = "./modules/epg"
  tenant_id          = aci_tenant.workshop1_tnt.id
  bd_id              = aci_bridge_domain.fixed_services_bd1.id
  ap_name            = "security"
  epg_name           = "malware1"
  contracts_consumed = [aci_contract.spike.id]
  contracts_provided = []
}

/*
	This section deals with contracts
*/

resource "aci_contract" "kubernetes" {
  tenant_dn = aci_tenant.workshop1_tnt.id
  name      = "kubernetes_services"
}

resource "aci_contract_subject" "kubernetes" {
  contract_dn = aci_contract.kubernetes.id
  name        = "kubernetes"
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
  contract_dn = aci_contract.databases.id
  name        = "databases"
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
  contract_dn = aci_contract.security.id
  name        = "security"
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
  contract_dn = aci_contract.spike.id
  name        = "spike"
  relation_vz_rs_subj_filt_att = [
    module.filter_web1.id,
    module.filter_database1.id
  ]
}

# May be helpful to include this in a contract module 
module "contract_export1" {
  source                  = "./modules/contract_export"
  exported_contract_name  = "spike_contract"
  description             = "exported contract from workshop"
  tenant_source_id        = aci_tenant.workshop1_tnt.id
  tenant_destination_id   = aci_tenant.workshop2_tnt.id
  tenant_source_name      = aci_tenant.workshop1_tnt.name
  tenant_destination_name = aci_tenant.workshop2_tnt.name
  contract_to_export      = aci_contract.spike.name
}

/*
	This section deals with filters
*/

module "filter_web1" {
  source             = "./modules/filter_tcp"
  tenant_id          = aci_tenant.workshop1_tnt.id
  filter_name        = "web"
  filter_description = "Web filter"
  filter_entry_name  = "http"
  tcp_port           = "80"
}

module "filter_web2" {
  source             = "./modules/filter_tcp"
  tenant_id          = aci_tenant.workshop1_tnt.id
  filter_name        = "web"
  filter_description = "Web filter"
  filter_entry_name  = "https"
  tcp_port           = "443"
}


module "filter_database1" {
  source             = "./modules/filter_tcp"
  tenant_id          = aci_tenant.workshop1_tnt.id
  filter_name        = "database"
  filter_description = "database filter"
  filter_entry_name  = "sql"
  tcp_port           = "1521"
}

module "filter_database2" {
  source             = "./modules/filter_tcp"
  tenant_id          = aci_tenant.workshop1_tnt.id
  filter_name        = "database"
  filter_description = "database filter"
  filter_entry_name  = "sql2"
  tcp_port           = "1121"
}


data "aci_physical_domain" "pdom" {
  name = "Heroes_phys"
}

resource "aci_application_profile" "ap1" {
  tenant_dn = aci_tenant.workshop1_tnt.id
  name      = "phy_app"
}

resource "aci_application_epg" "test" {
  application_profile_dn = aci_application_profile.ap1.id
  name                   = "phy1"
  #relation_fv_rs_dom_att = [data.aci_physical_domain.pdom.id]

}

resource "aci_epg_to_domain" "test_phy" {
  application_epg_dn = aci_application_epg.test.id
  tdn                = data.aci_physical_domain.pdom.id
}


resource "aci_epg_to_static_path" "path1" {
  application_epg_dn = aci_application_epg.test.id
  tdn                = "topology/pod-1/protpaths-101-102/pathep-[Heroes_FI-2A]"
  instr_imedcy       = "immediate"
  encap              = "vlan-1200"
}

resource "aci_epg_to_static_path" "path2" {
  application_epg_dn = aci_application_epg.test.id
  tdn                = "topology/pod-1/protpaths-101-102/pathep-[Heroes_FI-2B]"
  instr_imedcy       = "immediate"
  encap              = "vlan-1200"
}