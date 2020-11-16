### kubernetes clusters ###
resource "aci_application_profile" "ap1" {
	tenant_dn = var.tenant_id
	name      = var.ap_name
}
resource "aci_application_epg" "epg1" {
	application_profile_dn  = aci_application_profile.ap1.id
	relation_fv_rs_bd       = var.bd_id
	name                    = var.epg_name
	relation_fv_rs_cons     = var.contracts_consumed
  relation_fv_rs_prov     = var.contracts_provided
}
