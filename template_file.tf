data "template_file" "rds" {
  template = "${file("user_data.tpl")}"

  vars = {
    rds_endpoint = module.rds_cluster.endpoint
    rds_user     = module.rds_cluster.master_username
  }
}
