resource "oci_core_subnet" "test_subnet" {
    cidr_block = "192.168.254.0/24"
    compartment_id = var.compartment_ocid
    vcn_id = "ocid1.vcn.oc1.eu-stockholm-1.amaaaaaa74h264yamqz6ymd2uvgg5rsono3ifrm6fqtttmliy5dqaimggqka"
    prohibit_public_ip_on_vnic = true
}