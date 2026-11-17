terraform {
  required_version = ">= 1.17.0"

  required_providers {
    openstack = {
        source = "terraform-provider-openstack/openstack"
        version = "3.4.0"
    }
  }
}