terraform {
  required_providers {
    aci = {
      source = "ciscodevnet/aci"
      version = "= 0.5.2"
    }
  }
  required_version = ">= 0.13"
}
