output "sync" {
  value = "sysdig"
  depends_on = [null_resource.sysdig_bind]
}
