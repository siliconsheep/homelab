resource "vault_policy" "this" {
  for_each = fileset(path.module, "policies/*.{json,hcl}")

  name   = trimsuffix(trimsuffix(basename(each.key), ".hcl"), ".json")
  policy = file(each.key)
}
