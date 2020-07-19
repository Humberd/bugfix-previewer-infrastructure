module "app" {
  source = "../../schema/app"
  aws_access_key_id = "aa"
  aws_access_secret_key = "aa"
}

module "load_balancer" {
  source = "../../schema/load_balancer"
}
