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

resource "aci_application_profile" "kubernetes1" {
	tenant_dn = aci_tenant.workshop1_tnt.id
	name      = "kubernetes"
}
resource "aci_application_epg" "cluster1" {
	application_profile_dn  = aci_application_profile.kubernetes1.id
	relation_fv_rs_bd       = aci_bridge_domain.dynamic_services_bd1.id
	name                    = "cluster1"
	# consume a contract
	#relation_fv_rs_cons    = [
  #	aci_contract.web_services.id
	#]
}
resource "aci_application_epg" "cluster2" {
	application_profile_dn  = aci_application_profile.kubernetes1.id
	relation_fv_rs_bd       = aci_bridge_domain.dynamic_services_bd1.id
	name                    = "cluster2"
	# consume a contract
	#relation_fv_rs_cons    = [
  #	aci_contract.web_services.id
	#]
}


resource "aci_application_profile" "fixed_services_db" {
	tenant_dn = aci_tenant.workshop1_tnt.id
	name      = "databases"
}
resource "aci_application_epg" "database1" {
	application_profile_dn  = aci_application_profile.fixed_services_db.id
	relation_fv_rs_bd       = aci_bridge_domain.fixed_services_bd1.id 
	name                    = "database1"
	# consume a contract
	#relation_fv_rs_cons    = [
  #	aci_contract.web_services.id
	#]
}
resource "aci_application_epg" "database2" {
	application_profile_dn  = aci_application_profile.fixed_services_db.id
	relation_fv_rs_bd       = aci_bridge_domain.fixed_services_bd1.id 
	name                    = "database2"
	# consume a contract
	#relation_fv_rs_cons    = [
  #	aci_contract.web_services.id
	#]
}