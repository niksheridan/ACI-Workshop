# note the payload must align to the left with no indent
resource "aci_rest" "exported_contact" {
  path = "/api/mo/${var.tenant_destination_id}/cif-exported_contact.json"
	#depends_on = var.contract_to_export
  payload = jsonencode({
  "imdata"=[
		{
		"vzCPIf"={
			"attributes"={
					"annotation"="",
					"descr"="this contract is a banana",
					"dn"="uni/tn-${var.tenant_source_name}/cif-exported_contact",
					"name"="exported_contact",
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
								"tDn"="uni/tn-${var.tenant_destination_name}/brc-${var.contract_to_export}"
							}
						}
					}
				]
			}
		}
  ]
})
}

