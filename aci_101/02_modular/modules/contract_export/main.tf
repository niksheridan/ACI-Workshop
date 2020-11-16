# note the payload must align to the left with no indent
resource "aci_rest" "exported_contact" {
  path = "/api/mo/${var.tenant_destination_id}/cif-${var.exported_contract_name}.json"
	#depends_on = var.contract_to_export
  payload = jsonencode({
  "imdata"=[
		{
		"vzCPIf"={
			"attributes"={
					"annotation"="",
					"descr"=var.description,
					"dn"="uni/tn-${var.tenant_destination_name}/cif-${var.exported_contract_name}",
					"name"=var.exported_contract_name,
					"nameAlias"="",
					"ownerKey"="",
					"ownerTag"=""
				},
				"children"=[
					{
						"vzRsIf"={
							"attributes"={
								"annotation"="",
								"prio"="unspecified",
								"tDn"="uni/tn-${var.tenant_source_name}/brc-${var.contract_to_export}"
							}
						}
					}
				]
			}
		}
  ]
})
}

