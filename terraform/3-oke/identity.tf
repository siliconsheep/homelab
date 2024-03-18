resource "oci_identity_dynamic_group" "k8s-node-dynamic-group" {
  compartment_id = var.tenancy
  description    = "Dynamic group for Kubernetes worker nodes"
  matching_rule  = "Any { tag.Siliconsheep.Cluster.value='${oci_containerengine_cluster.k8s-cluster.name}'}"
  name           = "siliconsheep-k8s-nodes"

  defined_tags = local.defined_tags
}


resource "oci_identity_policy" "k8s-node-policy" {
  compartment_id = var.tenancy
  description    = "Policy for Kubernetes worker nodes"
  name           = "siliconsheep-k8s-policy"
  statements = [
    # Allows Vault pods to access its backend and KMS keys
    "Allow dynamic-group '${oci_identity_dynamic_group.k8s-node-dynamic-group.name}' to read buckets in tenancy",
    "Allow dynamic-group '${oci_identity_dynamic_group.k8s-node-dynamic-group.name}' to manage objects in tenancy where all {target.bucket.tag.Siliconsheep.Service='Vault'}",
    # Allow instances to list and mount block volumes (which will be used by Longhorn)
    # "Allow dynamic-group '${oci_identity_dynamic_group.k8s-node-dynamic-group.name}' to use volumes in tenancy",
    # "Allow dynamic-group '${oci_identity_dynamic_group.k8s-node-dynamic-group.name}' to use instances in tenancy",
    # "Allow dynamic-group '${oci_identity_dynamic_group.k8s-node-dynamic-group.name}' to manage volume-attachments in tenancy",
    # Allow instances to use Vault KMS keys
    "Allow dynamic-group '${oci_identity_dynamic_group.k8s-node-dynamic-group.name}' to use keys in tenancy",
    # Allow cluster-autoscaler to manage node pools
    "Allow dynamic-group '${oci_identity_dynamic_group.k8s-node-dynamic-group.name}' to manage cluster-node-pools in tenancy",
    "Allow dynamic-group '${oci_identity_dynamic_group.k8s-node-dynamic-group.name}' to manage instance-family in tenancy",
    "Allow dynamic-group '${oci_identity_dynamic_group.k8s-node-dynamic-group.name}' to use subnets in tenancy",
    "Allow dynamic-group '${oci_identity_dynamic_group.k8s-node-dynamic-group.name}' to read virtual-network-family in tenancy",
    "Allow dynamic-group '${oci_identity_dynamic_group.k8s-node-dynamic-group.name}' to use vnics in tenancy",
    "Allow dynamic-group '${oci_identity_dynamic_group.k8s-node-dynamic-group.name}' to inspect compartments in tenancy",
  ]

  defined_tags = local.defined_tags
}
