terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "6.31.0"
    }
  }
}

provider "oci" {
  region              = "us-sanjose-1"
  auth                = "SecurityToken"
  config_file_profile = "learn-terraform"
}

resource "oci_core_vcn" "internal" {
  dns_label      = "internal"
  cidr_block     = "172.16.0.0/20"
  compartment_id = "<your_compartment_OCID_here>"
  display_name   = "My interval VCN"
}
